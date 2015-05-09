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
          if e then
            true
          else
            false
          end }.inject([]) { |acc, elem|
          if acc.length == 0
            [elem]
          elsif acc[0]
            if acc[0] == elem
              [false, elem+1].concat(acc[1..-1])
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
      if r == row && c == column && !@board[r, c]
        value
        # The rest of the board
      else
        @board[r, c]
      end
    }

    Board.new(matrix:nboard)
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
      @test.msg1 = "Player 1, it's your turn!"
      @test.msg2 = "Player 2, it's not your turn."
      @test.save
    end
    # Print out boards
    @playerboard = Board.new(str:((@test.player1turn) ? @test.board1 : @test.board2)).board
    @opponentboard = Board.new(str:((@test.player1turn) ? @test.board2 : @test.board1)).board
    @cur_pid = current_user.id
  end

  # Move and place piece
  def move
    @test = Game2048.find_by_pid1(current_user.id)
    if !@test
      @test = Game2048.find_by_pid2(current_user.id)
    end
    # Params holds user input from POST request
    # TODO: game id's
    dir = params[:dir]
    row = params[:row].to_i
    col = params[:col].to_i
    val = params[:val].to_i

    # Move and place piece must both be valid until turn ends
    if @test.player1turn && (current_user.id == @test.pid1)
      @test.board1 = Board.new(str: @test.board1).apply_move(str2dir(dir)).to_s
      @test.board2 = Board.new(str: @test.board2).place_piece(row, col, val).to_s
      @test.player1turn = !@test.player1turn
      @test.msg1 = "Player 1, it's not your turn."
      @test.msg2 = "Player 2, it's your turn!"
      @test.save
    elsif !@test.player1turn && (current_user.id == @test.pid2)
      @test.board2 = Board.new(str: @test.board2).apply_move(str2dir(dir)).to_s
      @test.board1 = Board.new(str: @test.board1).place_piece(row, col, val).to_s
      @test.player1turn = !@test.player1turn
      @test.msg1 = "Player 1, it's your turn!"
      @test.msg2 = "Player 2, it's not your turn."
      @test.save
    end

    # Redirect to show() to display updated board
    redirect_to action: "show"
  end
end
