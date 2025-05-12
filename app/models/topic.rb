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
end
