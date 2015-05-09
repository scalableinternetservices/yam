class AddMsgsToGame2048s < ActiveRecord::Migration
  def change
    add_column :game2048s, :msg1, :string
    add_column :game2048s, :msg2, :string
  end
end
