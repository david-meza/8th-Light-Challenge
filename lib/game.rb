require 'pry'
require 'colorize'

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

# Manages board-related functionality such as rendering and checking for victory
class Board

  # Initialize the board as blank unless we are passed one (can expand to saving a game)
  def initialize(board_arr = nil)
    # I'll use a 2D array instead of one giant array
    @board_arr = board_arr || Array.new(3){Array.new(3)}
  end

  def add_piece(coords, piece)
    if location_valid?(coords)
      # On the board, the axes are actually reversed (rows are x and cols are y)
      @board_arr[coords[1]][coords[0]] = piece
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

    def location_valid?(coords)
      if inside_board?(coords)
        coordinates_available?(coords)
      end
    end

    def inside_board?(coords)
      inside = coords.all? { |value| (0..2).include?(value)  }
      puts "Coordinates are out of bounds. Try something between 0,0 and 2,2".yellow unless inside
      inside
    end

    def coordinates_available?(coords)
      available = @board_arr[coords[1]][coords[0]].nil?
      puts "There is already a piece in that cell. Try a different one".yellow unless available
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

# Controls the flow of the game
class Game

  def initialize
    @board = Board.new
  end

  def start_game
    print_welcome
    print_game_type
    select_players
    print_selected_players
    select_first_player
    print_game_start

    loop do
      puts "It is now #{@current_player.name}'s turn.".colorize(:cyan)
      @board.render
      @current_player.get_coordinates
      break if game_is_over
      switch_players
    end

  end

    private

    def print_welcome
      puts "Welcome to my Tic Tac Toe game"
      puts "Let's start by setting up our game"
      print "First, select the marker player #1 will use " + "(X or O or any other symbol):".light_blue.on_light_white + " "
      @piece1 = gets.strip[0].to_sym
      print "Great, how about the marker for player #2? "
      @piece2 = gets.strip[0].to_sym
      ask_for_piece_again if @piece1 == @piece2
    end

    def ask_for_piece_again
      puts "Both pieces can't be the same! What's the fun in that".yellow
      print "Please enter a marker for player #2 again "
      @piece2 = gets.strip[0].to_sym
      ask_for_piece_again if @piece1 == @piece2
    end

    def print_game_type
      puts "Ok! Now let's continue with selecting our game type"
      puts "(1) Human v. Human"
      puts "(2) Human v. Computer"
      puts "(3) Computer v. Computer"
      print "Enter your selection here: "
    end

    def select_players
      input = gets.strip

      case input
      when "1" || "(1)" || "1."
        print "What's your name?".red.on_light_white + " "
        p1_name = gets.chomp
        print "And player #2's name?".red.on_light_white + " "
        p2_name = gets.chomp
        @player1 = Human.new(p1_name, @piece1, @board)
        @player2 = Human.new(p2_name, @piece2, @board)
      when "2" || "(2)" || "2."
        print "What's your name?".red.on_light_white + " "
        p1_name = gets.chomp
        @player1 = Human.new(p1_name, @piece1, @board)
        @player2 = Computer.new(nil, @piece2, @board)
      when "3" || "(3)" || "3."
        @player1 = Computer.new(nil, @piece1, @board)
        @player2 = Computer.new(nil, @piece2, @board)
      else
        puts "Sorry, I didn't understand that. Try selecting 1, 2, or 3".colorize(:yellow)
        # Make recursive call until we get a good input
        select_players
      end
    end

    def print_selected_players
      puts "Great. So this will be a game of " + "#{@player1.class.to_s} v. #{@player2.class.to_s}".light_blue.on_light_white
      print "Now who will move first (select 1 or 2)? "
    end

    def select_first_player
      input = gets.strip
      case input
      when "1" || "(1)" || "1."
        @current_player = @player1
      when "2" || "(2)" || "2."
        @current_player = @player2
      else
        puts "Sorry, I didn't understand that. Try selecting 1, 2".colorize(:yellow)
        # Make recursive call until we get a good input
        select_first_player
      end
    end

    def print_game_start
      puts "Ok, ok, enough questions, let's get this game started!"
      puts
    end

    def game_is_over
      check_victory || check_draw
    end

    def check_victory
      win = @board.winning_combination?(@current_player.piece)
      puts "Congratulations #{@current_player.name}, you win!".colorize(:green) if win
      win
    end

    def check_draw
      draw = @board.full?
      puts "Bummer, you've drawn...".colorize(:light_blue).on_blue.underline if draw
      draw
    end

    def switch_players
      @current_player = (@current_player == @player1) ? @player2 : @player1
    end

end


game = Game.new
game.start_game
