class CreateGame2048s < ActiveRecord::Migration
  def change
    create_table :game2048s do |t|
      t.string :board1 # TODO: Add limit, accuonting for commas
      t.string :board2
      t.boolean :player1turn
      t.timestamps null: false
    end
  end
end
