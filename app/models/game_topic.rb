# == Schema Information
#
# Table name: game_topics
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :integer
#  topic_id   :integer
#
class GameTopic < ApplicationRecord
  # validations

  # direct associations
  belongs_to :game
  belongs_to :topic
end
