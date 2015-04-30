#!/bin/ruby 

require 'matrix'
require 'io/console'

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
    return @board
  end

  # TODO: Test this; makes a string representing
  # a board to be entered into model 
  # Board.initialize with string arg will give
  # a board from such a string
  def to_s
    str = @board.row_vectors.inject("") {|r_acc,r_elem|
      r_acc + r_elem.to_a.inject("") {|acc,elem|
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
        collapse_row(@board.column(3).to_a.reverse).reverse,
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

    Board.new(nboard)
  end

  def collapse_row(row)
    nrow =
    (row.select {|e| if e then true else false end}.inject([]) {|acc,elem| 
      if acc.length == 0 
        [elem]
      elsif acc[0]
        if acc[0] == elem 
          [false,elem+1].concat(acc[1..-1])
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
            if r == row && c == column && !@board[r,c]
             value
            # The rest of the board
          else 
           @board[r,c] 
         end
       }

       Board.new(nboard)
     end

     # Used only for console version
     def cli_print
      str = ""
      @board.row_size.times do |i|
        str += @board.row(i).to_a.join(",") + "\n"
      end
      str
    end

    # TODO: Check usage: initialize(matrix: someMatrix, str: "esrf")
  def initialize(matrix=nil, str=nil)
    if matrix
      @board = matrix
    # Make board from string held by model 
    # TODO: Test this!
    elsif str
      vals = str.split(",")
      @board = Matrix[
      vals.slice(0,3).map   {|x| if (x == 0) then false else x.to_i end },
      vals.slice(4,7).map   {|x| if (x == 0) then false else x.to_i end },
      vals.slice(8,11).map  {|x| if (x == 0) then false else x.to_i end },
      vals.slice(12,15).map {|x| if (x == 0) then false else x.to_i end }]

    else
      @board = Matrix.build(4, 4) {|r,c|
                if(r==0 && c==0)
                    1
                elsif (r==0 && c==1)
                    1
                else
                    false
                end
            }
    end
  end
  end

  class Game
    public
    # Scaffolding for commandline 2048 (one board)
    def play()
      currentboard = Board.new
      currentboard.cli_print
      loop do
        loop do
          nextboard = currentboard.apply_move(key2sym(read_char))
          if nextboard != currentboard
            currentboard = nextboard
            break
          end
        end
        currentboard.cli_print
        loop do 
          puts "Place a piece."
          print "RCV: "
          input = gets.chomp.split("").map {|elem| elem.to_i}
                # input validation
                if (input[0] >= 0 && input[0] < 4 && input[1] >= 0 && input[1] < 4 && (input[2] == 1 || input[2] == 2))
                  nextboard = currentboard.place_piece(*input)
                  if (nextboard != currentboard)
                    currentboard = nextboard 
                    currentboard.cli_print
                    break
                  end
                end
              end
            end
          end

          private
    # Read in keyboard input
    # Original from https://gist.github.com/acook/4190379
    def read_char
      STDIN.echo = false
      STDIN.raw!

      input = STDIN.getc.chr
      if input == "\e" then
        input << STDIN.read_nonblock(3) rescue nil
        input << STDIN.read_nonblock(2) rescue nil
      end
    ensure
      STDIN.echo = true
      STDIN.cooked!

      return input
    end
    def key2sym(input_char)
      case input_char
      when "\e[A"
        :up
      when "\e[B"
        :down
      when "\e[C"
        :right
      when "\e[D"
        :left
        # TODO: Add "quit" key 
      end
    end
  end

class Game2048Controller < ApplicationController
  # TODO: Single game at one time for now
  def initialize

  end

  # Print formatted grid from model data of boards
  # model_board is the string held by the model
  # Returns a formatted string with text-based board for display
  def print(model_board)
      vals = model_board.split(",")

      board_matrix = Matrix[
        vals.slice(0,4).map  {|x| if (x == 0) then 0 else x.to_i end },
        vals.slice(4,4).map  {|x| if (x == 0) then 0 else x.to_i end },
        vals.slice(8,4).map  {|x| if (x == 0) then 0 else x.to_i end },
        vals.slice(12,4).map {|x| if (x == 0) then 0 else x.to_i end }
      ]

      result = ""
      # Get each row as an array and then join for formatting
      board_matrix.row_vectors.each do |row_vec|
        # "-" for empty cells, number literal otherwise
        formatted_vec = row_vec.map do |elem| 
          if (elem == false)
            "-" 
          else 
            elem
          end
        end
        result << formatted_vec.to_a.join("  ") + "\n" 
      end
  end

  # Display updated board
  def show
    # TODO: Convert to actual model-interaction code
    @test = Game2048.take
    if ! @test
      @test = Game2048.new
      emptyboard = Board.new

      # Game2048 model has two string attributes,
      # to hold both the boards
      @test.board1 = emptyboard.to_s
      @test.board2 = emptyboard.to_s
      @test.player1turn = true
      @test.save
    end

    @message = "Place your piece and move your board"
    # Print out boards
    @display_board1 = print(@test.board1)
    @display_board2 = print(@test.board2)
  end

  # Move and place piece
  def move 
    # Params holds user input from POST request
    dir = params[:dir]
    row = params[:row]
    col = params[:col]
    val = params[:val]
    # puts "Params: #{dir}, #{row}, #{col}, #{val}"
    # Move and place piece must both be valid until turn ends
    if(@player1turn)
      @p1board = @p1board.apply_move(str2dir(dir))
      @p2board = @p2board.place_piece(row.to_i,col.to_i,val.to_i)
    else
      @p2board = @p2board.apply_move(str2dir(dir))
      @p1board = @p1board.place_piece(row.to_i,col.to_i,val.to_i)
    end
    @player1turn = !@player1turn

    # Redirect to show() to display updated board
    redirect_to action: "show"
  end
end
