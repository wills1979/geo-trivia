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

    parsed_gmaps_body = JSON.parse(HTTP.get(gmaps_api_url))

    # extract data
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
    the_game.difficulty = params.fetch("query_difficulty")
    if current_user
      the_game.user_id = current_user.id
    end

    if the_game.valid?
      the_game.save
      redirect_to("/games/#{the_game.id}", { :notice => "Game created successfully." })
    else
      redirect_to("/games", { :alert => the_game.errors.full_messages.to_sentence })
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
      number_of_pages = 5
      search_radius_m = (the_game.search_radius * 1000 * 1.60934).round.clamp(10, 10_000)
      wiki_params = {
        "format": "json",
        "list": "geosearch",
        "gscoord": "#{the_game.latitude}|#{the_game.longitude}",
        "gslimit": "#{number_of_pages}",
        "gsradius": "#{search_radius_m}",
        "action": "query",
      }

      wiki_response = HTTP.get(wiki_url, params: wiki_params)

      parsed_wiki_response = JSON.parse(wiki_response)

      pages = parsed_wiki_response.fetch("query").fetch("geosearch")

      pages.each do |page|
        page_id = page.fetch("pageid")

        page_params = {
          "action": "parse",
          "pageid": page_id.to_s,
          "format": "json",
          "prop": "text",
          "redirects": "true",
        }

        pages_data = JSON.parse(HTTP.get(wiki_url, params: page_params))

        title = pages_data.fetch("parse").fetch("title")

        # wikipedia_text
        html = pages_data.fetch("parse").fetch("text").fetch("*")
        sanitized_html = ActionView::Base.full_sanitizer.sanitize(html)
        wikipedia_text = remove_after(sanitized_html, "References[edit]")

        # latitude
        latitude = page.fetch("lat")

        # longitude
        longitude = page.fetch("lon")

        # save new topics
        new_topic = Topic.new
        new_topic.name = title
        new_topic.longitude = longitude
        new_topic.latitude = latitude
        new_topic.wikipedia_text = wikipedia_text
        new_topic.save

        sleep(0.1.seconds)
      end

      # find new relevant topics


    end

    

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
