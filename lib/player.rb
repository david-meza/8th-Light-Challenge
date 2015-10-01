require 'colorize'
require 'pry'

# Handles all player-related functionality
class Player

  attr_reader :piece, :name

  def initialize(name = "Mystery Player", piece, board)
    @name = name
    @piece = piece
    @board = board
  end

end


class Computer < Player

  def initialize(name = "Mystery Player", piece, board, piece_opponent)
    @name = name
    @piece = piece
    @board = board
    @piece_opponent = piece_opponent
  end

  def get_coordinates
    notify_user
    board_copy = deep_dupe(@board.board_arr)
    coords = find_best_move(board_copy)
    @board.add_piece(coords, @piece)
  end

    private

    def notify_user
      puts "#{name} will now perform its move!".light_cyan.on_magenta
      # Putting our insanely fast computers to rest API request style (jk)!
      sleep 1.5
    end

    # Make a deep copy of the board so we can make fake attempts at placing pieces
    # without affecting the references to the original array
    def deep_dupe(arr)
      copy = []
      arr.each do |inner_element|
        if inner_element.is_a?(Array)
          copy << deep_dupe(inner_element)
        else
          copy << inner_element
        end
      end
      copy
    end

    def find_best_move(board_copy)
      test = Board.new(board_copy)
      find_winning_move(test, @piece) || find_not_losing_move(test) || perform_any_available_move(test)
    end

    def find_winning_move(test, piece)
      3.times do |x|
        3.times do |y|
          if test.add_piece([x,y], piece, true)
            if test.winning_combination?(piece)
              return p [x, y]
            else
              test.remove_piece([x,y], piece)
            end
          end
        end
      end
      nil
    end

    # For clarity's sake. This is just a wrapper
    def find_not_losing_move(test)
      find_winning_move(test, @piece_opponent)
    end

    def perform_any_available_move(test)
      return [1,1] if test.board_arr[1][1].nil?
      coords = [rand(3), rand(3)]
      until test.add_piece(coords, @piece, true)
        coords = [rand(3), rand(3)]
      end
      coords
    end

end

class Human < Player

  def get_coordinates
    loop do
      coords = ask_for_coordinates
      # If coords are in the proper format
      if validate_coordinates_format(coords)
        # If piece can be placed on Board
        if @board.add_piece(coords, @piece)
          break
        end
      end
    end
  end

    private

    def validate_coordinates_format(coords)
      valid = coords.is_a?(Array) && coords.size == 2
      puts "Your coordinates are not in the right format. Try x,y (e.g '1,1')".colorize(:yellow) unless valid
      valid
    end

    def ask_for_coordinates
      print "#{@name}(#{@piece}), enter your coordinates in the form x,y: ".colorize(:blue)
      # In Ruby strings to_i return 0 so we don't need to worry about validating whether it's an int (it won't explode in our faces)
      gets.strip.split(",").map(&:to_i)
    end

end