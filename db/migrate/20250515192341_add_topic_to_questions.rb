class AddTopicToQuestions < ActiveRecord::Migration[7.1]
  def change
    add_reference :questions, :topic, null: false, foreign_key: true
  end
end
