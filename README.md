# PokerChip
This app fully simulates the game of Unlimited Texas Hold'em on iOS devices. With this app, players no longer need large amounts of heavy physical chips normally required for the game. Players can join a game hosted by anyone connecting to the same WiFi network. All a player has to do to join a game is click on Join Game and wait for the host's name to appear! This app completely follows the rules of the game, including four rounds of actions available (pre-flop, flop, turn, river). Furthermore, the application also automates the assignment of positions such as Dealer, Small Blind, and Big Blind. Also, the application also keeps track of user's chip count and automates the process of chip transferring to the winner of the pot of every hand. Whenever it's a player's turn, a player can make any valid move according to Texas Hold'em rules such as call, raise, fold, check, and also going ALL-IN! Players can also check other players' statistics that are stored persistently on each player's device by using the information icon ride beside each player. Below, we will first demonstrate the app and then go into the implementation details.

## Screenshots Showing a Complete Game Process

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 20 48 34](https://github.com/user-attachments/assets/6b434897-9de1-4300-bb1a-1c6db920d142 | width=100)
At first, one player can host a game by hitting Host Game. Every player can also decide how much chips to bring into a game through the slider on top.

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


## All-In Chip Calculations
![image](https://github.com/user-attachments/assets/7f41a97d-2ac5-4af8-a0a6-4b5c0ab35987)
Notice at the start of this game, Player 1 has less chips than Player 2.

![image](https://github.com/user-attachments/assets/16c22626-1790-437c-ba68-c8aca91110f0)
Here Player 1 and Player 2 both go all-in. Assuming Player 1 wins, Player 1 should not be able to take Player 2's entire stack according to Texas Hold'em Rules.

![image](https://github.com/user-attachments/assets/a2b948bf-00b7-4d55-ae99-a82b65095e11)
Therefore, after choosing Player 1, the app automatically recognizes that Player 1 cannot win the entire pot. The remainder of Player 2's stack can then be returned to Player 2.

![image](https://github.com/user-attachments/assets/3d13a8fb-a53d-4d9b-bea4-efd4e473b86b)
Just like this, Player 2 gets their 28 back.


## Screenshots Showing Additional Features

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 20 51 19](https://github.com/user-attachments/assets/61b9d563-906f-4e74-a19e-ed91c5614899)
The information icon beside each player in the game can bring up this page of statistics of a player. When playing in a game, each player's statistics is available for other players to view. This statistics is stored locally in each player's device persistently with SwiftData. Whenever a player joins a game, the statistics is sent to the host and then sent to every player in the game through the network connection. Since the statistics is stored locally, a player's statistics can follow the player no matter who the player plays with.

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 20 49 02](https://github.com/user-attachments/assets/30348433-bc43-40f1-be49-0a4f22b2dfa2)
A player can also store multiple profiles on their device through modifying the local PlayerRecords. A player can choose which profile to join a game with if the player wants to separate their records from playing with different people.

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 20 49 02](https://github.com/user-attachments/assets/9d7ce24c-92eb-43e9-a6e7-78f7970bb22a)
Here's a menu for extra features on the host's device. When a hand goes wrong, the host can end the hand and disburse the chip in the pot.

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 20 49 02](https://github.com/user-attachments/assets/527137a4-5d72-4f58-ab3a-58ca3ef38a55)
When a host ends a game, every player's winning or loss is calculated and shown.

![image](https://github.com/user-attachments/assets/c1e82554-9628-41ff-b2f7-5fcf0e33e29d)
Notice a player who is not a host can also choose to leave the game first.

![image](https://github.com/user-attachments/assets/fc376364-a98e-4999-ae82-9670a7304239)
When a player does leave the game first, the player is shown his winning or loss.

![image](https://github.com/user-attachments/assets/50e335fa-cb19-429d-b7d0-1a5ec737fa2a)
When the game ends, the player who leaves earlier also has their winning or loss shown.

![image](https://github.com/user-attachments/assets/3f988f6a-41ac-460d-ae41-7f76a1f4f324)
Whenever a mistake is made by selecting the wrong winner of the pot, the host can revert its action by restoring the pot.

![image](https://github.com/user-attachments/assets/8078adb0-f97c-4985-94fb-de8daeb00380)
After restoring the pot and giving the pot to the correct winner, here's the result.

![image](https://github.com/user-attachments/assets/16d00249-f2c8-47b5-8712-b5a2b0ed63bd)
Any player can also acquire additional chips by hitting the buy in option in the menu in the top right corner.




### The app icon is from this following website.
<a href="https://www.flaticon.com/free-icons/poker" title="poker icons">Poker icons created by Freepik - Flaticon</a>
