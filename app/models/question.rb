# == Schema Information
#
# Table name: questions
#
#  id              :bigint           not null, primary key
#  attempts        :integer
#  challenge       :string
#  correct_answer  :string
#  correct_answers :integer
#  image           :string
#  option_a        :string
#  option_b        :string
#  option_c        :string
#  option_d        :string
#  share_correct   :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  topic_id        :bigint           not null
#
# Indexes
#
#  index_questions_on_topic_id  (topic_id)
#
# Foreign Keys
#
#  fk_rails_...  (topic_id => topics.id)
#
class Question < ApplicationRecord
  # validations
  validates :option_d, presence: true
  validates :option_c, presence: true
  validates :option_b, presence: true
  validates :option_a, presence: true
  validates :correct_answers, presence: true
  validates :correct_answer, presence: true
  validates :challenge, presence: true
  validates :attempts, presence: true

  # direct associations
  belongs_to :topic
  has_many :game_questions, dependent: :destroy

  # indirect associations
  has_many :games, through: :game_questions, source: :game
end
