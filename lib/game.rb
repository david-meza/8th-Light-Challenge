# Handles all player-related functionality
class Player
  attr_reader :name, :piece

  def initialize(name = "Mystery Player", piece, board)
    @name = name
    @piece = piece
    @board = board
  end


end

# Manages board-related functionality such as rendering and checking for victory
class Board

  attr_reader :board_arr

  # Initialize the board as blank unless we are passed one (can expand to saving game)
  def initalize(board_arr = nil)
    # I'll use a 2D array instead of one giant array
    @board_arr = board_arr || Array.new(3){Array.new(3)}
  end

  def render
  end

  def winning_combination?(piece)
  end

  def full?
  end

end

class Computer < Player

end

class Human < Player

end

# Controls the flow of the game
class Game

  def initialize
    print_instructions
    select_players
    @board = Board.new
  end

  def select_players
    input = gets.strip

    case input
    when "1" || "(1)" || "1."
      @player1 = Human.new
      @player2 = Human.new
    when "2" || "(2)" || "2."
      @player1 = Human.new
      @player2 = Computer.new
    when "2" || "(2)" || "2."
      @player1 = Computer.new
      @player2 = Computer.new
    else
      puts "Sorry, I didn't understand that. Try selecting 1, 2, or 3"
      select_players
    end
  end

  def print_instructions
    puts "Welcome to my Tic Tac Toe game"
    puts "Please select your game type:"
    puts "(1) Human v. Human"
    puts "(2) Human v. Computer"
    puts "(3) Computer v. Computer"
  end

  def play

    loop do
      @board.render
      @current_player.get_coordinates
      break if game_is_over
      switch_players
    end

  end

  def game_is_over
    check_victory || check_draw
  end

  def check_victory
    win = @board.winning_combination?(@current_player.piece)
    puts "Congratulations #{@current_player.name}, you win!" if win
    win
  end

  def check_draw
    draw = @board.full?
    puts "Bummer, you've drawn..."
    draw
  end

  def switch_players
    @current_player = (@current_player == @player1) ? @player2 : @player1
  end

end


class Game
  def initialize
    @board = ["0", "1", "2", "3", "4", "5", "6", "7", "8"]
    @com = "X"
    @hum = "O"
  end

  def start_game
    puts "Welcome to my Tic Tac Toe game"
    puts "|_#{@board[0]}_|_#{@board[1]}_|_#{@board[2]}_|\n|_#{@board[3]}_|_#{@board[4]}_|_#{@board[5]}_|\n|_#{@board[6]}_|_#{@board[7]}_|_#{@board[8]}_|\n"
    puts "Please select your spot."
    until game_is_over(@board) || tie(@board)
      get_human_spot
      if !game_is_over(@board) && !tie(@board)
        eval_board
      end
      puts "|_#{@board[0]}_|_#{@board[1]}_|_#{@board[2]}_|\n|_#{@board[3]}_|_#{@board[4]}_|_#{@board[5]}_|\n|_#{@board[6]}_|_#{@board[7]}_|_#{@board[8]}_|\n"
    end
    puts "Game over"
  end

  def get_human_spot
    spot = nil
    until spot
      spot = gets.chomp.to_i
      if @board[spot] != "X" && @board[spot] != "O"
        @board[spot] = @hum
      else
        spot = nil
      end
    end
  end

  def eval_board
    spot = nil
    until spot
      if @board[4] == "4"
        spot = 4
        @board[spot] = @com
      else
        spot = get_best_move(@board, @com)
        if @board[spot] != "X" && @board[spot] != "O"
          @board[spot] = @com
        else
          spot = nil
        end
      end
    end
  end

  def get_best_move(board, next_player, depth = 0, best_score = {})
    available_spaces = []
    best_move = nil
    board.each do |s|
      if s != "X" && s != "O"
        available_spaces << s
      end
    end
    available_spaces.each do |as|
      board[as.to_i] = @com
      if game_is_over(board)
        best_move = as.to_i
        board[as.to_i] = as
        return best_move
      else
        board[as.to_i] = @hum
        if game_is_over(board)
          best_move = as.to_i
          board[as.to_i] = as
          return best_move
        else
          board[as.to_i] = as
        end
      end
    end
    if best_move
      return best_move
    else
      n = rand(0..available_spaces.count)
      return available_spaces[n].to_i
    end
  end

  def game_is_over(b)

    [b[0], b[1], b[2]].uniq.length == 1 ||
    [b[3], b[4], b[5]].uniq.length == 1 ||
    [b[6], b[7], b[8]].uniq.length == 1 ||
    [b[0], b[3], b[6]].uniq.length == 1 ||
    [b[1], b[4], b[7]].uniq.length == 1 ||
    [b[2], b[5], b[8]].uniq.length == 1 ||
    [b[0], b[4], b[8]].uniq.length == 1 ||
    [b[2], b[4], b[6]].uniq.length == 1
  end

  def tie(b)
    b.all? { |s| s == "X" || s == "O" }
  end

end

game = Game.new
game.start_game
