class QuestionsController < ApplicationController
  def index
    matching_questions = Question.all

    @list_of_questions = matching_questions.order({ :created_at => :desc })

    render({ :template => "questions/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_questions = Question.where({ :id => the_id })

    @the_question = matching_questions.at(0)

    render({ :template => "questions/show" })
  end

  def create
    the_question = Question.new
    the_question.challenge = params.fetch("query_challenge")
    the_question.image = params.fetch("query_image")
    the_question.correct_answer = params.fetch("query_correct_answer")
    the_question.option_a = params.fetch("query_option_a")
    the_question.option_b = params.fetch("query_option_b")
    the_question.option_c = params.fetch("query_option_c")
    the_question.option_d = params.fetch("query_option_d")
    the_question.correct_answers = params.fetch("query_correct_answers")
    the_question.attempts = params.fetch("query_attempts")
    the_question.share_correct = params.fetch("query_share_correct")

    if the_question.valid?
      the_question.save
      redirect_to("/questions", { :notice => "Question created successfully." })
    else
      redirect_to("/questions", { :alert => the_question.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_question = Question.where({ :id => the_id }).at(0)

    the_question.challenge = params.fetch("query_challenge")
    the_question.image = params.fetch("query_image")
    the_question.correct_answer = params.fetch("query_correct_answer")
    the_question.option_a = params.fetch("query_option_a")
    the_question.option_b = params.fetch("query_option_b")
    the_question.option_c = params.fetch("query_option_c")
    the_question.option_d = params.fetch("query_option_d")
    the_question.correct_answers = params.fetch("query_correct_answers")
    the_question.attempts = params.fetch("query_attempts")
    the_question.share_correct = params.fetch("query_share_correct")

    if the_question.valid?
      the_question.save
      redirect_to("/questions/#{the_question.id}", { :notice => "Question updated successfully."} )
    else
      redirect_to("/questions/#{the_question.id}", { :alert => the_question.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_question = Question.where({ :id => the_id }).at(0)

    the_question.destroy

    redirect_to("/questions", { :notice => "Question deleted successfully."} )
  end
end
