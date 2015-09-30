require 'pry'
require 'colorize'

# Handles all player-related functionality
class Player
  attr_accessor :name
  attr_reader :piece

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
    puts "Your coordinates are not in the right format. Try x,y (e.g '1,1')" unless valid
    valid
  end

  def ask_for_coordinates
    puts "#{@name}(#{@piece}), enter your coordinates in the form x,y:".colorize(:blue)
    gets.strip.split(",").map(&:to_i)
  end

end

# Manages board-related functionality such as rendering and checking for victory
class Board

  attr_reader :board_arr

  # Initialize the board as blank unless we are passed one (can expand to saving a game)
  def initialize(board_arr = nil)
    # I'll use a 2D array instead of one giant array
    @board_arr = board_arr || Array.new(3){Array.new(3)}
  end

  def add_piece(coords, piece)
    # On the board, the axes are actually reversed
    @board_arr[coords[1]][coords[0]] = piece
  end

  def render
    puts
    puts "x       0   1   2"
    puts "------------------"
    puts "y |"
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
    winning_diagonal(piece) || winning_horizontal(piece) || winning_vertical(piece)
  end

  def full?
    # Does every cell contain a piece?
    @board_arr.all? { |row| row.none?(&:nil?)  }
  end

    private

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
      # Store the result in an instance variable so we only generate it once
      return @h if @h
      hor_arr = [];
      3.times do |i|
        hor_arr << [ @board_arr[i][0], @board_arr[i][1], @board_arr[i][2] ]
      end
      @h = hor_arr
    end

    def winning_vertical(piece)
      verticals.any? { |col| col.all? { |cell| cell == piece }  }
    end

    def verticals
      return @v if @v
      vert_arr = [];
      3.times do |i|
        vert_arr << [ @board_arr[0][i], @board_arr[1][i], @board_arr[2][i] ]
      end
      @v = vert_arr
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
      puts "It is now #{@current_player.name}'s turn."
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
      print "First, select the marker player #1 will use (X or O or any other symbol): "
      @piece1 = gets.strip[0].to_sym
      print "Great, how about the marker for player #2? "
      @piece2 = gets.strip[0].to_sym
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
        print "What's your name? "
        p1_name = gets.chomp
        print "And player #2's name? "
        p2_name = gets.chomp
        @player1 = Human.new(p1_name, @piece1, @board)
        @player2 = Human.new(p2_name, @piece2, @board)
      when "2" || "(2)" || "2."
        print "What's your name? "
        p1_name = gets.chomp
        @player1 = Human.new(p1_name, @piece1, @board)
        @player2 = Computer.new(nil, @piece2, @board)
      when "3" || "(3)" || "3."
        @player1 = Computer.new(nil, @piece1, @board)
        @player2 = Computer.new(nil, @piece2, @board)
      else
        puts "Sorry, I didn't understand that. Try selecting 1, 2, or 3"
        # Make recursive call until we get a good input
        select_players
      end
    end

    def print_selected_players
      puts "Great. So this will be a game of #{@player1.class.to_s} v. #{@player2.class.to_s}"
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
        puts "Sorry, I didn't understand that. Try selecting 1, 2"
        # Make recursive call until we get a good input
        select_first_player
      end
    end

    def print_game_start
      puts "Ok, ok, enough questions, let's get this game started!"
      puts
    end

    def game_is_over
      p (check_victory || check_draw)
    end

    def check_victory
      win = @board.winning_combination?(@current_player.piece)
      puts "Congratulations #{@current_player.name}, you win!" if win
      win
    end

    def check_draw
      draw = @board.full?
      puts "Bummer, you've drawn..." if draw
      draw
    end

    def switch_players
      @current_player = (@current_player == @player1) ? @player2 : @player1
    end

end


# class Game
#   def initialize
#     @board = ["0", "1", "2", "3", "4", "5", "6", "7", "8"]
#     @com = "X"
#     @hum = "O"
#   end

#   def start_game
#     puts "Welcome to my Tic Tac Toe game"
#     puts "|_#{@board[0]}_|_#{@board[1]}_|_#{@board[2]}_|\n|_#{@board[3]}_|_#{@board[4]}_|_#{@board[5]}_|\n|_#{@board[6]}_|_#{@board[7]}_|_#{@board[8]}_|\n"
#     puts "Please select your spot."
#     until game_is_over(@board) || tie(@board)
#       get_human_spot
#       if !game_is_over(@board) && !tie(@board)
#         eval_board
#       end
#       puts "|_#{@board[0]}_|_#{@board[1]}_|_#{@board[2]}_|\n|_#{@board[3]}_|_#{@board[4]}_|_#{@board[5]}_|\n|_#{@board[6]}_|_#{@board[7]}_|_#{@board[8]}_|\n"
#     end
#     puts "Game over"
#   end

#   def get_human_spot
#     spot = nil
#     until spot
#       spot = gets.chomp.to_i
#       if @board[spot] != "X" && @board[spot] != "O"
#         @board[spot] = @hum
#       else
#         spot = nil
#       end
#     end
#   end

#   def eval_board
#     spot = nil
#     until spot
#       if @board[4] == "4"
#         spot = 4
#         @board[spot] = @com
#       else
#         spot = get_best_move(@board, @com)
#         if @board[spot] != "X" && @board[spot] != "O"
#           @board[spot] = @com
#         else
#           spot = nil
#         end
#       end
#     end
#   end

#   def get_best_move(board, next_player, depth = 0, best_score = {})
#     available_spaces = []
#     best_move = nil
#     board.each do |s|
#       if s != "X" && s != "O"
#         available_spaces << s
#       end
#     end
#     available_spaces.each do |as|
#       board[as.to_i] = @com
#       if game_is_over(board)
#         best_move = as.to_i
#         board[as.to_i] = as
#         return best_move
#       else
#         board[as.to_i] = @hum
#         if game_is_over(board)
#           best_move = as.to_i
#           board[as.to_i] = as
#           return best_move
#         else
#           board[as.to_i] = as
#         end
#       end
#     end
#     if best_move
#       return best_move
#     else
#       n = rand(0..available_spaces.count)
#       return available_spaces[n].to_i
#     end
#   end

#   def game_is_over(b)

#     [b[0], b[1], b[2]].uniq.length == 1 ||
#     [b[3], b[4], b[5]].uniq.length == 1 ||
#     [b[6], b[7], b[8]].uniq.length == 1 ||
#     [b[0], b[3], b[6]].uniq.length == 1 ||
#     [b[1], b[4], b[7]].uniq.length == 1 ||
#     [b[2], b[5], b[8]].uniq.length == 1 ||
#     [b[0], b[4], b[8]].uniq.length == 1 ||
#     [b[2], b[4], b[6]].uniq.length == 1
#   end

#   def tie(b)
#     b.all? { |s| s == "X" || s == "O" }
#   end

# end

game = Game.new
game.start_game
