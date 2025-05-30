class GamesController < ApplicationController
  def remove_after(text, marker, include_marker: true)
    if include_marker
      text.sub(/#{Regexp.escape(marker)}.*/m, "")
    else
      text.sub(/#{Regexp.escape(marker)}/m) { |match| match }
          .sub(/(#{Regexp.escape(marker)})(.*)/m, '\1')
    end
  end

  def index
    if current_user
      matching_games = current_user.games
      @list_of_games = matching_games.order({ :created_at => :desc })
    end

    render({ :template => "games/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_games = Game.where({ :id => the_id })

    @the_game = matching_games.at(0)

    @questions = @the_game.questions

    render({ :template => "games/show" })
  end

  def create

    # turn user location into latitude and longitude plus formatted location name
    user_location = params.fetch("query_location")
    gmaps_api_location_input = CGI.escape user_location
    gmaps_api_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{gmaps_api_location_input}&key=#{ENV.fetch("GMAPS_KEY")}"

    parsed_gmaps_body = JSON.parse(HTTP.get(gmaps_api_url)) rescue {}

    location_results = parsed_gmaps_body["results"]
    location_results = [] unless location_results.is_a?(Array)

    # bail if no location found
    if location_results.empty?
      redirect_to("/games",
                  alert: "Sorry, we didn’t recognize that location. Please try again!") and return
    end

    formatted_address = parsed_gmaps_body.fetch("results").at(0).fetch("formatted_address")
    location = parsed_gmaps_body.fetch("results").at(0).fetch("geometry").fetch("location")

    the_game = Game.new
    the_game.location = formatted_address
    the_game.latitude = location.fetch("lat")
    the_game.longitude = location.fetch("lng")
    the_game.search_radius = params.fetch("query_search_radius")
    the_game.number_of_questions = params.fetch("query_number_of_questions")
    the_game.correct_answers = 0
    the_game.incorrect_answers = 0
    the_game.difficulty = params.fetch("query_difficulty", "easy")
    if current_user
      the_game.user_id = current_user.id
    end

    # find relevant topics
    relevant_topics = Topic.where(
      "3959 * acos(cos(radians(?)) * cos(radians(latitude)) *
   cos(radians(longitude) - radians(?)) +
   sin(radians(?)) * sin(radians(latitude))) < ?",
      the_game.latitude, the_game.longitude, the_game.latitude, the_game.search_radius
    )

    relevant_topic_ids = relevant_topics.pluck(:id)
    relevant_questions = Question.where(topic_id: relevant_topic_ids)

    # crosscheck relevant questions against previous games
    if current_user
      previous_games = current_user.games
      previous_question_ids = []
      previous_games.each do |game|
        previous_question_ids |= game.questions.pluck(:id)
      end

      relevant_question_ids = relevant_questions.pluck(:id) - previous_question_ids.uniq
      relevant_questions = relevant_questions.where(id: relevant_question_ids)
    end

    # check to see if we need to generate more questions
    if relevant_questions.count < the_game.number_of_questions

      # find new relevant topics
      wiki_url = "https://en.wikipedia.org/w/api.php"
      number_of_pages = 20
      search_radius_m = (the_game.search_radius * 1000 * 1.60934).round(1).to_i.clamp(10, 10_000)
      wiki_params = {
        "format": "json",
        "list": "geosearch",
        "gscoord": "#{the_game.latitude}|#{the_game.longitude}",
        "gslimit": "#{number_of_pages}",
        "gsradius": "#{search_radius_m}",
        "action": "query",
      }

      wiki_response = HTTP.get(wiki_url, params: wiki_params)

      parsed_wiki_response = JSON.parse(wiki_response) rescue {}

      query_section = parsed_wiki_response["query"]
      query_section = {} unless query_section.is_a?(Hash)

      pages = query_section["geosearch"]
      pages = [] unless pages.is_a?(Array)

      if pages.empty?
        redirect_to("/games",
                    alert: "Sorry, we couldn’t find any nearby Wikipedia pages. Please try a different location or radius.") and return
      end

      number_of_pages_to_save = 3
      pages.sample(number_of_pages_to_save).each do |page|
        page_id = page.fetch("pageid")

        page_params = {
          "action": "parse",
          "pageid": page_id.to_s,
          "format": "json",
          "prop": "text",
          "redirects": "true",
        }

        pages_data = JSON.parse(HTTP.get(wiki_url, params: page_params))

        title = pages_data.fetch("parse").fetch("title", "No title found")

        # wikipedia_text
        html = pages_data.fetch("parse").fetch("text").fetch("*", "#{the_game.location}")
        sanitized_html = ActionView::Base.full_sanitizer.sanitize(html)
        wikipedia_text = remove_after(sanitized_html, "References[edit]")

        # latitude
        latitude = page.fetch("lat", nil)

        # longitude
        longitude = page.fetch("lon", nil)

        # save new topics
        new_topic = Topic.new
        new_topic.name = title
        new_topic.longitude = longitude
        new_topic.latitude = latitude
        new_topic.wikipedia_text = wikipedia_text
        new_topic.save

        # create new relevant questions
        chat = OpenAI::Chat.new
        # chat.model = ""
        chat.system("You are a pub trivia host. The user will provide the text from a wikipedia page and you will create two fun multiple choice trivia questions. It is also okay to create broader trivia questions about the people, places, or area near which the described place is located. The trivia questions should be fun for a general audience and not repeat the same facts if possible.")
        chat.schema = '{
            "name": "trivia_questions",
            "schema": {
              "type": "object",
              "properties": {
                "questions": {
                  "type": "array",
                  "description": "A collection of trivia questions generated from the text.",
                  "items": {
                    "type": "object",
                    "properties": {
                      "question_text": {
                        "type": "string",
                        "description": "The text of the trivia question."
                      },
                      "answers": {
                        "type": "object",
                        "description": "Possible answers for the trivia question.",
                        "properties": {
                          "a": {
                            "type": "string",
                            "description": "Answer option a."
                          },
                          "b": {
                            "type": "string",
                            "description": "Answer option b."
                          },
                          "c": {
                            "type": "string",
                            "description": "Answer option c."
                          },
                          "d": {
                            "type": "string",
                            "description": "Answer option d."
                          }
                        },
                        "required": [
                          "a",
                          "b",
                          "c",
                          "d"
                        ],
                        "additionalProperties": false
                      },
                      "correct_answer": {
                        "type": "string",
                        "description": "The letter of the correct answer (a, b, c, or d)."
                      },
                      "difficulty": {
                        "type": "string",
                        "description": "The level of difficulty for the trivia question.",
                        "enum": [
                          "easy",
                          "medium",
                          "hard"
                        ]
                      }
                    },
                    "required": [
                      "question_text",
                      "answers",
                      "correct_answer",
                      "difficulty"
                    ],
                    "additionalProperties": false
                  }
                }
              },
              "required": [
                "questions"
              ],
              "additionalProperties": false
            },
            "strict": true
          }'
        chat.user(new_topic.wikipedia_text)
        chat_response = chat.assistant!

        chat_response.fetch("questions").each do |response|
          # add questions

          question = Question.new
          question.challenge = response.fetch("question_text")
          question.topic_id = new_topic.id

          question.option_a = response.fetch("answers").fetch("a")
          question.option_b = response.fetch("answers").fetch("b")
          question.option_c = response.fetch("answers").fetch("c")
          question.option_d = response.fetch("answers").fetch("d")
          question.correct_answer = response.fetch("correct_answer")

          question.correct_answers = 0
          question.attempts = 0
          question.share_correct = 0

          question.save!
        end
      end

      # reselect relevant questions

      # find relevant topics
      relevant_topics = Topic.where(
        "3959 * acos(cos(radians(?)) * cos(radians(latitude)) *
   cos(radians(longitude) - radians(?)) +
   sin(radians(?)) * sin(radians(latitude))) < ?",
        the_game.latitude, the_game.longitude, the_game.latitude, the_game.search_radius
      )

      relevant_topic_ids = relevant_topics.pluck(:id)
      relevant_questions = Question.where(topic_id: relevant_topic_ids)

      # crosscheck relevant questions against previous games
      if current_user
        previous_games = current_user.games
        previous_question_ids = []
        previous_games.each do |game|
          previous_question_ids |= game.questions.pluck(:id)
        end

        relevant_question_ids = relevant_questions.pluck(:id) - previous_question_ids.uniq
        relevant_questions = relevant_questions.where(id: relevant_question_ids)
      end
    end

    # save the game
    if the_game.valid?
      the_game.save
      redirect_to("/games/#{the_game.id}", { :notice => "Game created successfully." })
    else
      redirect_to("/games", { :alert => the_game.errors.full_messages.to_sentence })
    end

    # assign questions to the game
    game_questions = relevant_questions.sample(the_game.number_of_questions)

    game_questions.each do |relevant_question|
      # create GameQuestion record
      game_question = GameQuestion.new
      game_question.question_id = relevant_question.id
      game_question.game_id = the_game.id
      game_question.correct = false
      game_question.save
    end

    game_topic_ids = game_questions.pluck(:id)
    game_topic_ids.each do |id|
      # create GameTopic record
      game_topic = GameTopic.new
      game_topic.topic_id = id
      game_topic.game_id = the_game.id
      game_topic.save
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_game = Game.where({ :id => the_id }).at(0)

    the_game.destroy

    redirect_to("/games", { :notice => "Game deleted successfully." })
  end

  def score_results
    the_id = params.fetch("path_id")
    the_game = Game.where({ :id => the_id }).at(0)
    @answers = params[:answers] || {}

    # determine correct answers
    @correct_answers = @answers.keys.map { |id| [id, Question.where({ :id => id.to_i }).at(0).correct_answer] }.to_h
    @questions = the_game.questions

    results_list = []
    @questions.each do |question|
      if @answers.fetch(question.id.to_s, nil) != nil
        user_answer = @answers.fetch(question.id.to_s)
        correct_answer = @correct_answers.fetch(question.id.to_s)
        correct = [user_answer == correct_answer]
      else
        correct = [false]
      end

      results_list += correct

      # add data to Question table
      question.attempts += 1
      if correct.first
        question.correct_answers += 1
      end

      # update Question table
      question.share_correct = question.correct_answers.to_f / question.attempts
      question.save

      # update GameQuestion table
      game_question = GameQuestion.where({ :game_id => the_game.id }).where({ :question_id => question.id }).at(0)
      game_question.question_id = question.id
      game_question.game_id = the_game.id
      game_question.correct = correct.first
      game_question.answer = user_answer
      game_question.save
    end

    @results = @answers.keys.zip(results_list).to_h

    # calculate counts
    @count_correct = @results.select { |key, value| value == true }.length
    @count_total = the_game.number_of_questions

    # update Game table
    the_game.correct_answers = @count_correct
    the_game.incorrect_answers = @count_total - @count_correct

    if the_game.valid?
      the_game.save
      redirect_to("/results/#{the_game.id}", { :notice => "Game scored." })
    else
      redirect_to("/games/#{the_game.id}", { :alert => the_game.errors.full_messages.to_sentence })
    end
  end

  def show_results
    the_id = params.fetch("path_id")
    the_game = Game.where({ :id => the_id }).at(0)

    @results = {}
    @answers = {}
    @correct_answers = {}
    @questions = the_game.questions
    @questions.each do |question|
      Game.where({ :id => the_id }).at(0)
      @results[question.id] = question.game_questions.where({ :game_id => the_game.id }).where({ :question_id => question.id }).at(0).correct
      @answers[question.id] = question.game_questions.where({ :game_id => the_game.id }).where({ :question_id => question.id }).at(0).answer
      @correct_answers[question.id] = question.correct_answer
    end

    # calculate score
    @count_correct = @results.select { |key, value| value == true }.length
    @count_total = the_game.number_of_questions
    @score = @count_correct.to_f / @count_total

    render({ :template => "games/results" })
  end
end
