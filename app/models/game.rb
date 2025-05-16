# == Schema Information
#
# Table name: games
#
#  id                  :bigint           not null, primary key
#  correct_answers     :integer
#  difficulty          :string
#  incorrect_answers   :integer
#  latitude            :float
#  location            :string
#  longitude           :float
#  number_of_questions :integer
#  search_radius       :float
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :integer
#
class Game < ApplicationRecord
  # validations
  validates :search_radius, presence: true
  validates :number_of_questions, presence: true
  validates :location, presence: true
  validates :longitude, presence: true
  validates :latitude, presence: true
  validates :incorrect_answers, presence: true
  validates :difficulty, presence: true
  validates :correct_answers, presence: true

  # direct associations
  belongs_to :user, optional: true
  has_many :game_topics, dependent: :destroy
  has_many :game_questions, dependent: :destroy

  # indirect associations
  has_many :topics, through: :game_topics, source: :topic
  has_many :questions, through: :game_questions, source: :question
end
