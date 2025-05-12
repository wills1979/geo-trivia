class CreateGameQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :game_questions do |t|
      t.integer :question_id
      t.integer :game_id
      t.boolean :correct

      t.timestamps
    end
  end
end
