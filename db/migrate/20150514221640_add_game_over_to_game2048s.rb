class AddGameOverToGame2048s < ActiveRecord::Migration
  def change
    add_column :game2048s, :game_over, :boolean, :default => false
  end
end
