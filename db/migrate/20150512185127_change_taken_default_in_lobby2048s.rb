class ChangeTakenDefaultInLobby2048s < ActiveRecord::Migration
  def up
    change_column_default :lobby2048s, :taken, false
  end

  def down
    change_column_default :lobby2048s, :taken, nil
  end
end
