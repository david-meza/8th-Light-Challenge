require 'colorize'

# Manages board-related functionality such as rendering and checking for victory
class Board

  # Reader so AI can find it's best move
  attr_reader :board_arr

  # Initialize the board as blank unless we are passed one (can expand to saving a game)
  def initialize(board_arr = nil)
    # I'll use a 3x3 2D array instead of one giant array
    @board_arr = board_arr || Array.new(3) { Array.new(3) }
  end

  def add_piece(coords, piece, silence = false)
    # Returns nil (falsey), unless we explicitly return true
    if location_valid?(coords, silence)
      # On the board, the axes are actually reversed (rows are x and cols are y)
      @board_arr[coords[1]][coords[0]] = piece
      return true
    end

  end

  # For AI purposes only.
  def remove_piece(coords, piece)
    # Can't remove a piece that's not the computers
    if @board_arr[coords[1]][coords[0]] == piece
      @board_arr[coords[1]][coords[0]] = nil
    end
  end

  def render
    puts
    puts "x".colorize(:magenta) + "       0   1   2"
    puts "------------------".colorize(:light_black)
    puts "y".colorize(:magenta) + " |".colorize(:light_black)
    @board_arr.each_with_index do |row, row_index|
      print "#{row_index} |    "
      row.each_with_index do |cell, cell_index|
        # display an existing marker if any, otherwise blank
        cell.nil? ? print(" - ") : print(" #{cell.to_s} ")
        print "|" unless cell_index == 2
      end
      print "\n"
    end
    puts
  end

  def winning_combination?(piece)
    # Can this piece win the game in any of these combinations?
    winning_diagonal(piece) || winning_horizontal(piece) || winning_vertical(piece)
  end

  def full?
    # Does every cell contain a piece?
    @board_arr.all? { |row| row.none?(&:nil?)  }
  end

    private

    def location_valid?(coords, silence)
      if inside_board?(coords)
        coordinates_available?(coords, silence)
      end
    end

    def inside_board?(coords)
      inside = coords.all? { |value| (0..2).include?(value)  }
      puts "Coordinates are out of bounds. Try something between 0,0 and 2,2".yellow unless inside
      inside
    end

    def coordinates_available?(coords, silence)
      available = @board_arr[coords[1]][coords[0]].nil?
      puts "There is already a piece in that cell. Try a different one".yellow unless available || silence
      available
    end

    def winning_diagonal(piece)
      diagonals.any? { |diag| diag.all? { |cell| cell == piece  }  }
    end

    def diagonals
      [[ @board_arr[0][0],@board_arr[1][1],@board_arr[2][2] ],[ @board_arr[2][0],@board_arr[1][1],@board_arr[0][2] ]]
    end

    def winning_horizontal(piece)
      horizontals.any? { |row| row.all? { |cell| cell == piece }  }
    end

    def horizontals
      hor_arr = [];
      3.times do |i|
        hor_arr << [ @board_arr[i][0], @board_arr[i][1], @board_arr[i][2] ]
      end
      hor_arr
    end

    def winning_vertical(piece)
      verticals.any? { |col| col.all? { |cell| cell == piece }  }
    end

    def verticals
      vert_arr = [];
      3.times do |i|
        vert_arr << [ @board_arr[0][i], @board_arr[1][i], @board_arr[2][i] ]
      end
      vert_arr
    end

end