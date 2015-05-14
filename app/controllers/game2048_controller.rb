#!/bin/ruby 

require 'matrix'

def str2dir(str)
  case str
    when "up"
      :up
    when "down"
      :down
    when "left"
      :left
    when "right"
      :right
  end
end

# Board is immutable. State change operations return a new Board
# Boards hold 'false' for an empty cell
# and a number otherwise
class Board
  def board
    @board
  end

  # TODO: Test this; makes a string representing
  # a board to be entered into model 
  # Board.initialize with string arg will give
  # a board from such a string
  def to_s
    str = @board.row_vectors.inject("") { |r_acc, r_elem|
      r_acc + r_elem.to_a.inject("") { |acc, elem|
        if !elem
          acc + "0,"
        else
          acc + elem.to_s + ","
        end
      }
    }
    str.slice(0, str.length-1)
  end

  def apply_move(move)
    nboard = Matrix.build(4, 4)
    case move
      when :up
        nboard = Matrix.columns([
                                    collapse_row(@board.column(0)),
                                    collapse_row(@board.column(1)),
                                    collapse_row(@board.column(2)),
                                    collapse_row(@board.column(3))
                                ])
      when :down
        nboard = Matrix.columns([
                                    collapse_row(@board.column(0).to_a.reverse).reverse,
                                    collapse_row(@board.column(1).to_a.reverse).reverse,
                                    collapse_row(@board.column(2).to_a.reverse).reverse,
                                    collapse_row(@board.column(3).to_a.reverse).reverse
                                ])
      when :left
        nboard = Matrix[
            collapse_row(@board.row(0)),
            collapse_row(@board.row(1)),
            collapse_row(@board.row(2)),
            collapse_row(@board.row(3))
        ]
      when :right
        nboard = Matrix[
            collapse_row(@board.row(0).to_a.reverse).reverse,
            collapse_row(@board.row(1).to_a.reverse).reverse,
            collapse_row(@board.row(2).to_a.reverse).reverse,
            collapse_row(@board.row(3).to_a.reverse).reverse
        ]
      # TODO: todofunction adds another symbol
      # for when move is invalid, and user must try again
      when :broken
        @board
    end

    def !=(board)
      !(@board == board.board)
    end

    Board.new(matrix: nboard)
  end

  def collapse_row(row)
    nrow =
        (row.select { |e|
          if e!=0
            true
          else
            false
          end }.inject([]) { |acc, elem|
          if acc.length == 0
            [elem]
          elsif acc[0]!=0
            if acc[0] == elem
              [0, elem+1].concat(acc[1..-1])
            else
              acc.unshift(elem)
            end
          else # 0::xs,#
            acc[1..-1].unshift(elem)
          end
        }).reverse

    while nrow.size < row.size
      nrow << false
    end

    nrow.to_a
  end

  # Value is what user wants to plop in at (row, column)
  # Will return an identical board if a piece is already present (Check using !=)
  def place_piece(row, column, value)
    nboard = Matrix.build(4) { |r, c|
      # Matching coordinate and nothing already there
      if r == row && c == column && @board[r, c]==0
        value
        # The rest of the board
      else
        @board[r, c]
      end
    }

    Board.new(matrix:nboard)
  end

  # Returns true if board is full (game over), otherwise false
  def full
    nboard.each { |e| return false if e == 0}
    true # no empty spots
  end

  # TODO: Check usage: initialize(matrix: someMatrix, str: "esrf")
  def initialize(matrix: nil, str: nil)
    if matrix
      @board = matrix
      # Make board from string held by model
      # TODO: Test this!
    elsif str
      vals = str.split(",")
      @board = Matrix[
          vals.slice(0, 4).map { |x| x.to_i },
          vals.slice(4, 4).map { |x| x.to_i },
          vals.slice(8, 4).map { |x| x.to_i },
          vals.slice(12, 4).map { |x| x.to_i }
      ]
    else
      @board = Matrix.build(4, 4) { |r, c|
        if r == 0 && c == 0
          1
        elsif r == 0 && c == 1
          1
        else
          false
        end
      }
    end
  end
end

class Game2048Controller < ApplicationController

  #redirect to login if not logged in
  before_action :authenticate_user!

  # Print formatted grid from model data of boards
  # model_board is the string held by the model
  # Returns a formatted string with text-based board for display
  def print(model_board)
    vals = model_board.split(",")
    board_matrix = Matrix[

        vals.slice(0, 4).map { |x| x.to_i },
        vals.slice(4, 4).map { |x| x.to_i },
        vals.slice(8, 4).map { |x| x.to_i },
        vals.slice(12, 4).map { |x| x.to_i }
    ]

    result = []
    # Get each row as an array and then join for formatting
    board_matrix.row_vectors.each { |r| result << r.to_a }
    result
  end

  # Display updated board
  def show
    @test = Game2048.find_by_pid1(current_user.id)
    if !@test
      @test = Game2048.find_by_pid2(current_user.id)
    end
    if !@test
      @test = Game2048.new

      # TODO: take 2 users from waitlist instead of from all Users
      players = User.all
      # Game2048 model has two string attributes,
      # to hold both the boards
      @test.board1 = Board.new.to_s
      @test.board2 = @test.board1
      @test.player1turn = true
      @test.pid1 = players[0].id # TODO: pids of waitlisted users
      @test.pid2 = players[1].id
      @test.msg1 = "It's your turn!"
      @test.msg2 = "It's not your turn."
      @test.save
    end
    # Print out boards
    @jsonstring = @test.to_json
    @playerboard = Board.new(str:((@test.player1turn) ? @test.board1 : @test.board2)).board
    @opponentboard = Board.new(str:((@test.player1turn) ? @test.board2 : @test.board1)).board
    @cur_pid = current_user.id
  end

  def game_json
    idk = Game2048.find_by_id(params[:id])
    render(json: idk)
  end

  # Move and place piece
  def move
    @test = Game2048.find_by_pid1(current_user.id)
    if !@test
      @test = Game2048.find_by_pid2(current_user.id)
    end
    @jsonstring = @test.to_json
    # Params holds user input from POST request
    # TODO: game id's
    dir = params[:dir]
    row = params[:row].to_i
    col = params[:col].to_i
    val = params[:val].to_i

    # Move and place piece must both be valid until turn ends
    if @test.player1turn && (current_user.id == @test.pid1) # player 1's turn
      new_board1 = Board.new(str: @test.board1).apply_move(str2dir(dir)).to_s
      new_board2 = Board.new(str: @test.board2).place_piece(row, col, val).to_s
      if @test.board1 == new_board1 || @test.board2 == new_board2 # p1 made an invalid move; one of the boards didn't change
        @test.msg1 = "You made an invalid move."
      else
        @test.board1 = new_board1
        @test.board2 = new_board2
        @test.player1turn = !@test.player1turn
        @test.msg1 = "It's not your turn."
        @test.msg2 = "It's your turn!"
      end
      @test.save
    elsif !@test.player1turn && (current_user.id == @test.pid2) # player 2's turn
      new_board1 = Board.new(str: @test.board1).place_piece(row, col, val).to_s
      new_board2 = Board.new(str: @test.board2).apply_move(str2dir(dir)).to_s
      if @test.board1 == new_board1 || @test.board2 == new_board2 # p1 made an invalid move; one of the boards didn't change
        @test.msg2 = "You made an invalid move."
      else
        @test.board1 = new_board1
        @test.board2 = new_board2
        @test.player1turn = !@test.player1turn
        @test.msg1 = "It's your turn!"
        @test.msg2 = "It's not your turn."
      end
      @test.save
    end

    # Check if game is over
    if Board.new(str: @test.board1).full # board1 is full. p1 lost, p2 won
      @test.game_over = true
      @test.msg1 = "You lost."
      @test.msg2 = "You won!"
      @test.save
    elsif Board.new(str: @test.board2).full # board2 is full. p1 won, p2 lost
      @test.game_over = true
      @test.msg1 = "You won!"
      @test.msg2 = "You lost."
      @test.save
    end

    # Redirect to show() to display updated board
    redirect_to action: "show"
  end

  # Match-make current user with another ready user
  def make_match

    # TODO: Add locking via ActiveRecord's lock()

    # Add current user as ready-to-play
    Lobby2048.create(pid: current_user.id)

    # Get list of all ready-to-play users
    available = Lobby2048.where(taken: false)

    # Avoid loop if we're already taken
    if Lobby2048.find_by_pid1(current_user.id).taken
      redirect_to action: "show"
    end

    # Wait until we have at least one pair
    while available.size < 2
      available = Lobby2048.where(taken: false)

      # If no users left to be paired, we're done here
      break if available.size == 0 
    end

    # Get a random available user that's not us
    while true
      player2 = available.sample
      break if player2.id != current_user.id
    end

    # We have a basic locking system:
    # If the other player is not yet taken, mark them and
    # the current user as taken, then create a new game for them
    # Abort at any point if current player is taken

    # TODO: Is player2 guaranteed not taken by that earlier where()?
    # TODO: Introduce variables to distinguish player references
    if !(player2.taken) 
      player2.taken = true
      if Lobby2048.find_by_pid1(current_user.id).taken
        player2.taken = false
        redirect_to action: "show"
      else
        curPlayer = Lobby2048.find_by_pid1(current_user.id)
        curPlayer.taken = true
        # Create new Game2048 instance with selected pair
        Game2048.create(pid1: current_user.id, pid2: player2.id,
                        board1: Board.new.to_s, board2: Board.new.to_s,
                        player1turn: true)

      end

      # TODO: Delete the pair from the waiting Lobby
    end
  end

  def end_game
    # Retrieve game from db
    @test = Game2048.find_by_pid1(current_user.id)
    if !@test
      @test = Game2048.find_by_pid2(current_user.id)
    end

    # Disassociate current player's pid from game
    if current_user.id == @test.pid1
      @test.pid1 = nil
    else
      @test.pid2 = nil
    end
    @test.save

    # Delete game if both players are disassociated
    if !@test.pid1 && !@test.pid2
      Game2048.destroy(@test.id)
    end

    redirect_to action: "show"
  end
end
