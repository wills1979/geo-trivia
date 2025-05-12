class GameTopicsController < ApplicationController
  def index
    matching_game_topics = GameTopic.all

    @list_of_game_topics = matching_game_topics.order({ :created_at => :desc })

    render({ :template => "game_topics/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_game_topics = GameTopic.where({ :id => the_id })

    @the_game_topic = matching_game_topics.at(0)

    render({ :template => "game_topics/show" })
  end

  def create
    the_game_topic = GameTopic.new
    the_game_topic.game_id = params.fetch("query_game_id")
    the_game_topic.topic_id = params.fetch("query_topic_id")

    if the_game_topic.valid?
      the_game_topic.save
      redirect_to("/game_topics", { :notice => "Game topic created successfully." })
    else
      redirect_to("/game_topics", { :alert => the_game_topic.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_game_topic = GameTopic.where({ :id => the_id }).at(0)

    the_game_topic.game_id = params.fetch("query_game_id")
    the_game_topic.topic_id = params.fetch("query_topic_id")

    if the_game_topic.valid?
      the_game_topic.save
      redirect_to("/game_topics/#{the_game_topic.id}", { :notice => "Game topic updated successfully."} )
    else
      redirect_to("/game_topics/#{the_game_topic.id}", { :alert => the_game_topic.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_game_topic = GameTopic.where({ :id => the_id }).at(0)

    the_game_topic.destroy

    redirect_to("/game_topics", { :notice => "Game topic deleted successfully."} )
  end
end
