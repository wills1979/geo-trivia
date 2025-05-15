class RemoveTopicFromGames < ActiveRecord::Migration[7.1]
  def change
    remove_reference :games, :topic, null: false, foreign_key: true
  end
end
