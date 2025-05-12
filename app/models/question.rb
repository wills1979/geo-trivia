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
#
class Question < ApplicationRecord
end
