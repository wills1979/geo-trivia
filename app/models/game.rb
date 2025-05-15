# == Schema Information
#
# Table name: games
#
#  id                  :bigint           not null, primary key
#  correct_answers     :integer
#  difficulty          :string
#  incorrect_answers   :integer
#  latitude            :float
#  longitude           :float
#  number_of_questions :integer
#  search_radius       :float
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :integer
#
class Game < ApplicationRecord
end
