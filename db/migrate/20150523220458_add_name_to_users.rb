class AddNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gamer_tag, :string
    add_column :users, :description, :string
    add_column :users, :profile_image, :string, :default => "Happy"
  end
end
