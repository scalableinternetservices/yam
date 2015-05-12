class CreateLobby2048s < ActiveRecord::Migration
  def change
    create_table :lobby2048s do |t|
      t.integer :pid

      t.timestamps null: false
    end
  end
end
