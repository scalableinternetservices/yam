class AddRatingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :rating, :float, :default => 1000
  end
end
