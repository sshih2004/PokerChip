# PokerChip
This app fully simulates the game of Unlimited Texas Hold'em on iOS devices. With this app, players no longer need large amounts of heavy physical chips normally required for the game. Players can join a game hosted by anyone connecting to the same WiFi network. All a player has to do to join a game is click on Join Game and wait for the host's name to appear! This app completely follows the rules of the game, including four rounds of actions available (pre-flop, flop, turn, river). Furthermore, the application also automates the assignment of positions such as Dealer, Small Blind, and Big Blind. Also, the application also keeps track of user's chip count and automates the process of chip transferring to the winner of the pot of every hand. Whenever it's a player's turn, a player can make any valid move according to Texas Hold'em rules such as call, raise, fold, check, and also going ALL-IN! Players can also check other players' statistics that are stored persistently on each player's device by using the information icon ride beside each player. Below, we will first demonstrate the app and then go into the implementation details.

## Screenshots Showing a Complete Game Process

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 20 48 34](https://github.com/user-attachments/assets/6b434897-9de1-4300-bb1a-1c6db920d142)
At first, one player can host a game by hitting Host Game.

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 20 49 28](https://github.com/user-attachments/assets/27e138b8-b9b9-41d9-850f-2b6d1faf3c08)
After a player starts hosting a game, they then create an empty game room.

![Simulator Screenshot - iPhone 15 Pro Max - 2024-10-01 at 20 49 44](https://github.com/user-attachments/assets/476c8ea2-7932-4cc6-9692-e85139021375)
Other users can hit Search for games to look for any game hosted in the same WiFi network. When the desired game appears, simply click on the name of the host to join the game.

![Simulator Screenshot - iPhone 15 Plus - 2024-10-01 at 20 49 57](https://github.com/user-attachments/assets/555ff9ac-6fad-4712-8bb5-b05bd0f429c3)
Here's an example with 3 players in a game!

![image](https://github.com/user-attachments/assets/4a70105a-fa12-421d-b11b-b4a8816c9331)
The host can then hit Start, which is exclusive only to the host. Starting a hand and selecting a winner of the pot to transfer chips are exclusive to thhe host of the game.
Here, we can also see that the first player to act, Player 1, gets to choose from FOLD, CALL, and RAISE. Notice that the name of player to action will blink on the list of players as shown. This will occur on all devices in the same game to let every player know who's to action.

![image](https://github.com/user-attachments/assets/30ad212f-bc5b-4c78-b9bf-995b565b030c)
Player 1 decides to raise to 5, and Player 2 decides to call. Player 3 can now make a decision as the big blind. If Player 3 re-raises, the round of actions will start again and everyone before Player 3 get another turn to make a decision.

![image](https://github.com/user-attachments/assets/df16adcd-0d43-444b-aec4-cad6d646bf2b)
As shown here, Player 1 gets another round to make a decision because the wager is now 15 but not 5. Player 1 calls, and Player 2 folds. Therefore, for later rounds, only Player 1 and Player 3 remain in game and Player 2 is skipped because Player 2 has folded.

![image](https://github.com/user-attachments/assets/c97d098a-1011-4400-ba72-bd9e1a051bd8)
Here, Player 3 is expected to action because Player 2 has folded. Therefore, since small blind has folded, the first to action becomes next position, which is big blind.


![image](https://github.com/user-attachments/assets/29573e06-a43e-4b72-83f3-b0f9cf490792)
Just for demonstration purpose here, we assume Player 1 and Player 3 just check all the way till the hand ends. The host of the game can now determine who wins the game and selects the winner.

![image](https://github.com/user-attachments/assets/ab1ed8ac-d084-4aaa-9304-7772d2985ac7)
The host can then select a winner through this menu.

![image](https://github.com/user-attachments/assets/aadecad0-f137-4ab5-a09c-5d0195f00cc4)
After a winner is selected, notice how all the chip transfers are completed. Also keep in mind that chip counts of each players are updated instantly after a player makes an action to ensure every player in the game has the most up to date information of each player.







### The app icon is from this following website.
<a href="https://www.flaticon.com/free-icons/poker" title="poker icons">Poker icons created by Freepik - Flaticon</a>
