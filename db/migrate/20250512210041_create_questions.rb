class CreateQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :questions do |t|
      t.string :challenge
      t.string :image
      t.string :correct_answer
      t.string :option_a
      t.string :option_b
      t.string :option_c
      t.string :option_d
      t.integer :correct_answers
      t.integer :attempts
      t.float :share_correct

      t.timestamps
    end
  end
end
