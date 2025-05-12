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
      redirect_to("/games", { :notice => "Game created successfully." })
    else
      redirect_to("/games", { :alert => the_game.errors.full_messages.to_sentence })
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
      redirect_to("/games/#{the_game.id}", { :notice => "Game updated successfully."} )
    else
      redirect_to("/games/#{the_game.id}", { :alert => the_game.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_game = Game.where({ :id => the_id }).at(0)

    the_game.destroy

    redirect_to("/games", { :notice => "Game deleted successfully."} )
  end
end
