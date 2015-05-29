class ChangeGamerTagDefaultInUsers < ActiveRecord::Migration
  def change
    change_column_default :users, :gamer_tag, "Yam Player"
  end
end
