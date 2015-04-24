#!/bin/ruby 

require 'matrix'
require 'io/console'

# The board, in charge of tracking its own state
class Board
    def initialize(matrix=nil)
        # Boards hold 'false' for an empty cell
        # and a number otherwise
        if matrix
            @board = matrix
        else
            @board = Matrix.build(4, 4) { false }
        end
    end

    def board
        return @board
    end

    def apply_move(move) 
        nboard = Matrix.build(4, 4)
        case move
            when :up
                nboard = Matrix.columns(
                [
                    collapse_row(@board.column(0)),
                    collapse_row(@board.column(1)),
                    collapse_row(@board.column(2)),
                    collapse_row(@board.column(3))
                ]
                )
            when :down
                nboard = Matrix.columns(
                [
                    collapse_row(@board.column(0).to_a.reverse).reverse,
                    collapse_row(@board.column(1).to_a.reverse).reverse,
                    collapse_row(@board.column(2).to_a.reverse).reverse,
                    collapse_row(@board.column(3).to_a.reverse).reverse,
                ]
                )
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
        end

        def !=(board)
            !(@board == board.board)
        end

        # Update internal board
        Board.new(nboard)
    end

    #|> (Array.fold (fun acc elem -> 
                    #match (acc, elem) with
                    #| ([], y) -> [ y ]
                    #| (Contains(f) :: xs, Contains(s)) -> 
                        #if f = s then Empty :: Contains(f + 1) :: xs
                        #else Contains(s) :: Contains(f) :: xs
                    #| (Empty :: xs, Contains(s)) -> Contains(s) :: xs) [])
    # Collapse row
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
        }
        ).reverse

        while nrow.size < row.size
            nrow << false
        end

        nrow.to_a
    end



    # Value is what user wants to plop in at (row, column)
    def place_piece(row, column, value)
        #puts "Debug: #{row}, #{column}, #{value}"
        nboard = Matrix.build(4) { |r, c|
            # Matching coordinate and nothing already there
            if r == row && c == column && !@board[r,c]
               value
            # The rest of the board
            else 
               @board[r,c] 
            end
        }

        # Any additional work needed?
        Board.new(nboard)
    end

    def print
        @board.row_size.times do |i|
            puts @board.row(i).to_a.join(",")
        end
        puts ""
    end
end

class Game
    def initialize()
        @board = Board.new
        #@board.place_piece(0, 0, 1)
        @board.place_piece(3, 3, 1)
        @board.place_piece(2, 2, 1)
        @board.place_piece(0, 0, 2)
        @board.place_piece(1, 1, 2)
    end

public

    # Apply player move to board 
    def play()
        currentboard = Board.new.place_piece(3, 3, 1).place_piece(2, 2, 1).place_piece(0, 0, 2).place_piece(1, 1, 2)
        currentboard.print
        loop do
            loop do
                nextboard = currentboard.apply_move(key2sym(read_char))
                if nextboard != currentboard #TODO: Need to be able to compare
                    currentboard = nextboard
                    break
                end
            end
            currentboard.print
            loop do 
                puts "Place a piece."
                print "RCV: "
                input = gets.chomp.split("").map {|elem| elem.to_i}
                if (input[0] >= 0 && input[0] < 4 && input[1] >= 0 && input[1] < 4 && (input[2] == 1 || input[2] == 2))
                    nextboard = currentboard.place_piece(*input)
                    if (nextboard != currentboard)
                        currentboard = nextboard 
                        currentboard.print
                        break
                    end
                end
            end
        end
    end

    # Internal helper functions
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

# Map keyboard strokes to directions


### TESTING ###

# Passing
#puts "[ #{collapse_row( [false, false, false, false] ).join(",")} ]"
##puts "#{[1,false,1].select {|e| if e then true else false end}.join(",")}"
#puts "[ #{collapse_row( [false, 1,     false, false] ).join(",")} ]"
#puts "[ #{collapse_row( [1, false, 1] ).join(",")} ]"
#puts "[ #{collapse_row( [1, 1, 2, 3] ).join(",")} ]"

# test_board = Matrix[
#     [ false, false, false, false ],
#     [ false, 2,     false, false ],
#     [ false, false, false, false ],
#     [ false, false, false, false ]
# ]
# puts place_piece(test_board, 0, 0, 9)

new_game = Game.new
new_game.play
