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
    @board.each { |e| return false if e == 0}
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
    @game = Game2048.find_by_pid1(current_user.id)
    if !@game
      @game = Game2048.find_by_pid2(current_user.id)
    end

    @jsonstring = @game.to_json
    @cur_pid = current_user.id

    if current_user.id == @game.pid1
      if @game.player1turn
        @other_user = User.find_by_id(@game.pid2)
        @playerboard = Board.new(str: @game.board1).board
        @opponentboard = Board.new(str: @game.board2).board
        return render :show_player
      else
        @other_user = User.find_by_id(@game.pid2)
        @playerboard = Board.new(str: @game.board1).board
        @opponentboard = Board.new(str: @game.board2).board
        return render :show_waiter
      end
    else
      if !(@game.player1turn)
        @other_user = User.find_by_id(@game.pid1)
        @playerboard = Board.new(str: @game.board2).board
        @opponentboard = Board.new(str: @game.board1).board
        return render :show_player
      else
        @other_user = User.find_by_id(@game.pid1)
        @playerboard = Board.new(str: @game.board2).board
        @opponentboard = Board.new(str: @game.board1).board
        return render :show_waiter
      end
    end
    # Print out boards
  end

  def game_json
    idk = Game2048.find_by_id(params[:id])
    render(json: idk)
  end

  def match_json
    in_game = Game2048.find_by_pid1(current_user.id)

    if !in_game
      in_game = Game2048.find_by_pid2(current_user.id)
    end

    # Player is already in a game
    if in_game
      idk = {"in_match" => "yes"}
      render(json: idk)
      return
    end

    player1 = nil
    begin
      player1 = Lobby2048.find_by_pid(current_user.id)
      if player1.taken
        idk = {"in_match" => "no"}
        render(json: idk)
        return
      end
    # Current user not in database
    rescue
      idk = {"in_match" => "no"}
      render(json: idk)
      return
    end

    # Need at least one other available user who is not current user
    available = Lobby2048.where(taken: false).select { |x| x.pid != current_user.id }

    if available.size >= 1
      player2 = available.sample
      player2.taken = true
      player2.save

      player1.taken = true
      player1.save

      Game2048.create(pid1: current_user.id, pid2: player2.pid,
                        board1: Board.new.to_s, board2: Board.new.to_s,
                        player1turn: true)

      Lobby2048.find_by_pid(current_user.id).destroy
      Lobby2048.find_by_pid(player2.pid).destroy

      idk = {"in_match" => "yes"}
    else
      idk = {"in_match" => "no"}
    end

    render(json: idk)
  end

  # Move and place piece
  def move
    @game = Game2048.find_by_pid1(current_user.id)
    if !@game
      @game = Game2048.find_by_pid2(current_user.id)
    end

    if @game.game_over
      redirect_to action: "show"
      return
    end

    @jsonstring = @game.to_json

    # Params holds user input from POST request
    # TODO: game id's
    dir = params[:dir]
    row = params[:row].to_i
    col = params[:col].to_i
    val = params[:val].to_i

    # Move and place piece must both be valid until turn ends
    if @game.player1turn && (current_user.id == @game.pid1) # player 1's turn
      new_board1 = Board.new(str: @game.board1).apply_move(str2dir(dir)).to_s
      new_board2 = (Board.new(str: @game.board2).full) ? @game.board2 : Board.new(str: @game.board2).place_piece(row, col, val).to_s
      if @game.board1 == new_board1 || !Board.new(str: @game.board2).full && @game.board2 == new_board2 # p1 made an invalid move; one of the boards didn't change
        @game.msg1 = "You made an invalid move."
      else
        @game.board1 = new_board1
        @game.board2 = new_board2
        @game.player1turn = !@game.player1turn
        @game.msg1 = "It's not your turn."
        @game.msg2 = "It's your turn!"
      end
    elsif !@game.player1turn && (current_user.id == @game.pid2) # player 2's turn
      new_board1 = (Board.new(str: @game.board1).full) ? @game.board1 : Board.new(str: @game.board1).place_piece(row, col, val).to_s
      new_board2 = Board.new(str: @game.board2).apply_move(str2dir(dir)).to_s
      if !Board.new(str: @game.board1).full && @game.board1 == new_board1 || @game.board2 == new_board2 # p1 made an invalid move; one of the boards didn't change
        @game.msg2 = "You made an invalid move."
      else
        @game.board1 = new_board1
        @game.board2 = new_board2
        @game.player1turn = !@game.player1turn
        @game.msg1 = "It's your turn!"
        @game.msg2 = "It's not your turn."
      end
    end

    # Check if game is over
    gameboard = (current_user.id == @game.pid1) ? Board.new(str: @game.board1) : Board.new(str: @game.board2)
    # current player lost
    if !(gameboard != gameboard.apply_move(:up) || gameboard != gameboard.apply_move(:down) || gameboard != gameboard.apply_move(:left) || gameboard != gameboard.apply_move(:right))
      @game.game_over = true
      @game.msg1 = (current_user.id == @game.pid1) ? "You lost." : "You won!"
      @game.msg2 = (current_user.id == @game.pid2) ? "You lost." : "You won!"
      adjust_ratings(@game, current_user.id)
    end
    @game.save # only need to save once
    # Redirect to show() to display updated board
    redirect_to action: "show"
  end

  # Match-make current user with another ready user
  def join_match
    begin 
    # If already in-game, redirect to it
    in_game = Game2048.find_by_pid1(current_user.id)
    rescue
    end

    begin
      if !in_game
        in_game = Game2048.find_by_pid2(current_user.id)
      end
    rescue
    end

    if in_game
      redirect_to action: "show"
    else
      Lobby2048.create(pid: current_user.id)
      redirect_to action: "wait_room"
    end
    # If not already in game, redirect to waiting room, 
    # and AJAX there will continuously try to create a 
    # new game to join via match_json
  end

  def wait_room
    @jsonstring = ({"in_match" => "no"}).to_json
  end

  def end_game
    # Retrieve game from db
    @game = Game2048.find_by_pid1(current_user.id)
    if !@game
      @game = Game2048.find_by_pid2(current_user.id)
    end

    # Update messages and ratings
    if !@game.game_over
      @game.msg1 = "Game over!"
      @game.msg2 = "Game over!"
      adjust_ratings(@game, current_user.id)
    end

    # Mark game as completed
    @game.game_over = true

    # Disassociate current player's pid from game
    if current_user.id == @game.pid1
      @game.pid1 = nil
    else
      @game.pid2 = nil
    end

    @game.save

    # Delete game if both player pids are disassociated
    if !@game.pid1 && !@game.pid2
      Game2048.destroy(@game.id)
    end

    # Start a new game
    join_match
  end
end

def adjust_ratings(game, loser_id)
  winner = User.find_by_id((loser_id == game.pid1) ? game.pid2 : game.pid1)
  loser = User.find_by_id(loser_id)
  winner.rating = winner.rating * 0.99 + loser.rating / winner.rating * 20
  loser.rating = loser.rating * 0.99
  winner.save
  loser.save
end