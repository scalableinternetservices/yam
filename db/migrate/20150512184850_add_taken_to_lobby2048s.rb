class AddTakenToLobby2048s < ActiveRecord::Migration
  def change
    add_column :lobby2048s, :taken, :boolean
  end
end
