class GamesController < ApplicationController
  def index
    matching_games = Game.all

    @list_of_games = matching_games.order({ :created_at => :desc })

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
    the_game = Game.new
    the_game.latitude = params.fetch("query_latitude")
    the_game.longitude = params.fetch("query_longitude")
    the_game.search_radius = params.fetch("query_search_radius")
    the_game.number_of_questions = params.fetch("query_number_of_questions")
    the_game.correct_answers = params.fetch("query_correct_answers")
    the_game.incorrect_answers = params.fetch("query_incorrect_answers")
    the_game.difficulty = params.fetch("query_difficulty")
    the_game.user_id = params.fetch("query_user_id")

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

    while game_question_ids.length < (the_game.number_of_questions + 1) and tries < max_tries
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

  def update
    the_id = params.fetch("path_id")
    the_game = Game.where({ :id => the_id }).at(0)

    the_game.latitude = params.fetch("query_latitude")
    the_game.longitude = params.fetch("query_longitude")
    the_game.search_radius = params.fetch("query_search_radius")
    the_game.number_of_questions = params.fetch("query_number_of_questions")
    the_game.correct_answers = params.fetch("query_correct_answers")
    the_game.incorrect_answers = params.fetch("query_incorrect_answers")
    the_game.difficulty = params.fetch("query_difficulty")
    the_game.user_id = params.fetch("query_user_id")

    if the_game.valid?
      the_game.save
      redirect_to("/games/#{the_game.id}", { :notice => "Game updated successfully." })
    else
      redirect_to("/games/#{the_game.id}", { :alert => the_game.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_game = Game.where({ :id => the_id }).at(0)

    the_game.destroy

    redirect_to("/games", { :notice => "Game deleted successfully." })
  end
end
