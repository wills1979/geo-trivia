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
#  topic_id            :bigint           not null
#  user_id             :integer
#
# Indexes
#
#  index_games_on_topic_id  (topic_id)
#
# Foreign Keys
#
#  fk_rails_...  (topic_id => topics.id)
#
class Game < ApplicationRecord
end
