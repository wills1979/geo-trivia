class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.float :latitude
      t.float :longitude
      t.float :search_radius
      t.integer :number_of_questions
      t.integer :correct_answers
      t.integer :incorrect_answers
      t.string :difficulty
      t.integer :user_id

      t.timestamps
    end
  end
end
