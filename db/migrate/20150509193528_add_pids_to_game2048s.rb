class AddPidsToGame2048s < ActiveRecord::Migration
  def change
    add_column :game2048s, :pid1, :integer
    add_column :game2048s, :pid2, :integer
  end
end
