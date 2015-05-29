class AddPidIndexesToGame2048s < ActiveRecord::Migration
  def change
    add_index :game2048s, :pid1
    add_index :game2048s, :pid2
  end
end
