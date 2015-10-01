# 8th-Light-Challenge
My solution to implementing a better Tic Tac Toe game

### How to play

Just fork or clone this repo, and go to the /lib folder on your command-line interface. Then type `ruby game.rb` and follow the instructions to get you started. Have fun!

### Walkthrough

##### Game

The Game class found in `game.rb` is the heart of the game. It controls the flow of what happens and is essentially a good manager in that it delegates what has to be done to other modules and acts on the results of those processes. When this class is initialized, only a board is instantiated at that point. The main game loop `start_game` takes care of any additional necessary setup (not placed in the initializer so it doesn't block the actual Game class instantiation). All other methods were made private as they only pertain to this class and no other module needs to interact with them.

##### Board

The Board class found in `board.rb` takes care of managing any board-related functionality such as rendering and checking for victory. This particular class is slightly less encapsulated as say the game class because other classes depend on the results of board methods to take action. For example, the `winning_combination` method is used both by the game controller and the computer model to know if the game is over and to find the best computer move respectively. In addition, there is an attribute reader on the board array, so the board can be watched (though not modified), at any point by any other class.

##### Player

The player class handles all player-related functionality. The idea in making different classes for a `Human` and a `Computer` is that since they both inherit from the `Player` class, the `Player` class could contain methods that would be shared by both classes, though the situation for its use didn't come up. Both humans and computers have only one public class called `get_coordinates` which is called by the game controller to get a player's move. There is also an `attr_reader` on both the player's name and piece to make more informed comments to the player as to who's currently playing.

###### Computer (AI)

The computer is pretty smart. It'll follow the following procedure to perform a move:
1. First, it'll try to find a winning move
2. Second, it'll try to find a move that will prevent it from losing
3. Lastly, if none of these moves are plausible. It'll perform a random move, although it has a preference for placing its marker on the middle of the board if its available.

I also set a small sleep timeout so the computer's move won't be so sudden, but follows a more user-friendly flow. Lastly, one thing worth mentioning, is that for the AI to find its move, it makes a deep dupe of the board array. This was done because Ruby is a pass-by-reference language, so if we tried to find our move by doing something like `copy = @board.board_arr` we would actually just have a reference to the values inside the original array. So, any changes we made to the copy would also be reflected on the original array.