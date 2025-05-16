class AddLocationToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :location, :string
  end
end
