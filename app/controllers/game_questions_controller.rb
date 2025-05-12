class GameQuestionsController < ApplicationController
  def index
    matching_game_questions = GameQuestion.all

    @list_of_game_questions = matching_game_questions.order({ :created_at => :desc })

    render({ :template => "game_questions/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_game_questions = GameQuestion.where({ :id => the_id })

    @the_game_question = matching_game_questions.at(0)

    render({ :template => "game_questions/show" })
  end

  def create
    the_game_question = GameQuestion.new
    the_game_question.question_id = params.fetch("query_question_id")
    the_game_question.game_id = params.fetch("query_game_id")
    the_game_question.correct = params.fetch("query_correct", false)

    if the_game_question.valid?
      the_game_question.save
      redirect_to("/game_questions", { :notice => "Game question created successfully." })
    else
      redirect_to("/game_questions", { :alert => the_game_question.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_game_question = GameQuestion.where({ :id => the_id }).at(0)

    the_game_question.question_id = params.fetch("query_question_id")
    the_game_question.game_id = params.fetch("query_game_id")
    the_game_question.correct = params.fetch("query_correct", false)

    if the_game_question.valid?
      the_game_question.save
      redirect_to("/game_questions/#{the_game_question.id}", { :notice => "Game question updated successfully."} )
    else
      redirect_to("/game_questions/#{the_game_question.id}", { :alert => the_game_question.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_game_question = GameQuestion.where({ :id => the_id }).at(0)

    the_game_question.destroy

    redirect_to("/game_questions", { :notice => "Game question deleted successfully."} )
  end
end
