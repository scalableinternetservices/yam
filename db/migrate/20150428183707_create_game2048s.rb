class CreateGame2048s < ActiveRecord::Migration
  def change
    create_table :game2048s do |t|
      t.string :board1 # TODO: Make this 16 chars limit
      t.string :board2
      t.boolean :player1turn, :length => 16
      t.timestamps null: false
    end
  end
end
