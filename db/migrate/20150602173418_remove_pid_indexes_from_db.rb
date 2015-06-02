class RemovePidIndexesFromDb < ActiveRecord::Migration
  def change
    remove_index :game2048s, :pid1
    remove_index :game2048s, :pid2
    remove_index :lobby2048s, :pid
  end
end
