require 'colorize'

require_relative "board.rb"
require_relative "player.rb"

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

    puts "This is the final board".light_blue
    @board.render

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
        @player2 = Computer.new(@piece2, @board, @piece1)
      when "3" || "(3)" || "3."
        @player1 = Computer.new(@piece1, @board, @piece2)
        @player2 = Computer.new(@piece2, @board, @piece1)
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
        puts "Sorry, I didn't understand that. Try selecting 1 or 2".colorize(:yellow)
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
