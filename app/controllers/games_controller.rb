class GamesController < ApplicationController
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

    ## TODO: Make this elegant
    game_question_ids = []
    game_topic_ids = []
    tries = 0
    max_tries = 20

    while game_question_ids.length < (the_game.number_of_questions) and tries < max_tries
      tries += 1

      relevant_topic = relevant_topics.sample
      relevant_question = relevant_topic.questions.sample

      if !game_question_ids.include?(relevant_question.id)
        game_question_ids += [relevant_question.id]
        game_topic_ids += [relevant_topic.id]

        # create GameQuestion record
        game_question = GameQuestion.new
        game_question.question_id = relevant_question.id
        game_question.game_id = the_game.id
        game_question.correct = false
        game_question.save
      end
    end

    game_topic_ids.each do |id|
      # create GameTopic record
      game_topic = GameTopic.new
      game_topic.topic_id = id
      game_topic.game_id = the_game.id
      game_topic.save
    end
  end

  # def update
  #   the_id = params.fetch("path_id")
  #   the_game = Game.where({ :id => the_id }).at(0)

  #   the_game.latitude = params.fetch("query_latitude")
  #   the_game.longitude = params.fetch("query_longitude")
  #   the_game.search_radius = params.fetch("query_search_radius")
  #   the_game.number_of_questions = params.fetch("query_number_of_questions")
  #   the_game.correct_answers = params.fetch("query_correct_answers")
  #   the_game.incorrect_answers = params.fetch("query_incorrect_answers")
  #   the_game.difficulty = params.fetch("query_difficulty")
  #   the_game.user_id = params.fetch("query_user_id")

  #   if the_game.valid?
  #     the_game.save
  #     redirect_to("/games/#{the_game.id}", { :notice => "Game updated successfully." })
  #   else
  #     redirect_to("/games/#{the_game.id}", { :alert => the_game.errors.full_messages.to_sentence })
  #   end
  # end

  def destroy
    the_id = params.fetch("path_id")
    the_game = Game.where({ :id => the_id }).at(0)

    the_game.destroy

    redirect_to("/games", { :notice => "Game deleted successfully." })
  end

  def submit_results
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
        results_list += correct
      else
        results_list += [false]
      end

      # add data to Question table
      question.attempts += 1
      if correct == true
        question.correct_answers += 1
      end

      # update Question table
      question.share_correct = question.correct_answers.to_f / question.attempts
      question.save

      # update GameQuestion table
      game_question = GameQuestion.new
      game_question.question_id = question.id
      game_question.game_id = the_game.id
      game_question.correct = correct
      game_question.answer = user_answer
      game_question.save
    end

    @results = @answers.keys.zip(results_list).to_h

    # calculate score
    @count_correct = @results.select { |key, value| value == true }.length
    @count_total = @results.length
    @score = @count_correct.to_f / @count_total

    # update Game table
    the_game.correct_answers = @count_correct
    the_game.incorrect_answers = @count_total - @count_correct
    the_game.save

    render({ :template => "games/results" })
  end
end
