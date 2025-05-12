class CreateTopics < ActiveRecord::Migration[7.1]
  def change
    create_table :topics do |t|
      t.string :name
      t.float :longitude
      t.float :latitude
      t.string :image
      t.text :wikipedia_text

      t.timestamps
    end
  end
end
