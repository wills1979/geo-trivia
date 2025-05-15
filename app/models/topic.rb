# == Schema Information
#
# Table name: topics
#
#  id             :bigint           not null, primary key
#  image          :string
#  latitude       :float
#  longitude      :float
#  name           :string
#  wikipedia_text :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Topic < ApplicationRecord
  # validations
  validates :wikipedia_text, presence: true
  validates :name, presence: true
  validates :longitude, presence: true
  validates :latitude, presence: true

  # direct associations
  has_many :questions, dependent: :destroy
  has_many :game_topics, dependent: :destroy

  # indirect associations
  has_many :games, through: :game_topics, source: :game
end
