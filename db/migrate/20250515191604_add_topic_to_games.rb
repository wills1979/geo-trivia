class AddTopicToGames < ActiveRecord::Migration[7.1]
  def change
    add_reference :games, :topic, null: false, foreign_key: true
  end
end
