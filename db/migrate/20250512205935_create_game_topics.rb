class CreateGameTopics < ActiveRecord::Migration[7.1]
  def change
    create_table :game_topics do |t|
      t.integer :game_id
      t.integer :topic_id

      t.timestamps
    end
  end
end
