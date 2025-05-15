# == Schema Information
#
# Table name: game_questions
#
#  id          :bigint           not null, primary key
#  correct     :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  game_id     :integer
#  question_id :integer
#
class GameQuestion < ApplicationRecord
  # validations
  validates :correct, presence: true
  
  # direct associations
  belongs_to :game
  belongs_to :question

  # indirect associations
end
