class TopicsController < ApplicationController
  def index
    matching_topics = Topic.all

    @list_of_topics = matching_topics.order({ :created_at => :desc })

    render({ :template => "topics/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_topics = Topic.where({ :id => the_id })

    @the_topic = matching_topics.at(0)

    render({ :template => "topics/show" })
  end

  def create
    the_topic = Topic.new
    the_topic.name = params.fetch("query_name")
    the_topic.longitude = params.fetch("query_longitude")
    the_topic.latitude = params.fetch("query_latitude")
    the_topic.image = params.fetch("query_image")
    the_topic.wikipedia_text = params.fetch("query_wikipedia_text")

    if the_topic.valid?
      the_topic.save
      redirect_to("/topics", { :notice => "Topic created successfully." })
    else
      redirect_to("/topics", { :alert => the_topic.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_topic = Topic.where({ :id => the_id }).at(0)

    the_topic.name = params.fetch("query_name")
    the_topic.longitude = params.fetch("query_longitude")
    the_topic.latitude = params.fetch("query_latitude")
    the_topic.image = params.fetch("query_image")
    the_topic.wikipedia_text = params.fetch("query_wikipedia_text")

    if the_topic.valid?
      the_topic.save
      redirect_to("/topics/#{the_topic.id}", { :notice => "Topic updated successfully."} )
    else
      redirect_to("/topics/#{the_topic.id}", { :alert => the_topic.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_topic = Topic.where({ :id => the_id }).at(0)

    the_topic.destroy

    redirect_to("/topics", { :notice => "Topic deleted successfully."} )
  end
end
