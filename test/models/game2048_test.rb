require 'test_helper'

class Game2048Test < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def new_game(board1str, board2str)
    Game2048.new(board1: board1str,
                 board2: board2str, 
                 player1turn: true)
  end

  test "board type is Game2048" do 
    assert new_game("", "").class == Game2048.new.class, "Wrong class"
  end
end
