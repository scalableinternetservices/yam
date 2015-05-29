class AddPidIndexToLobby2048s < ActiveRecord::Migration
  def change
    add_index :lobby2048s, :pid
  end
end
