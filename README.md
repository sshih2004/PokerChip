# PokerChip
This app fully simulates the game of Unlimited Texas Hold'em on iOS devices. With this app, players no longer need large amounts of heavy physical chips normally required for the game. Players can join a game hosted by anyone connecting to the same WiFi network. All a player has to do to join a game is click on Join Game and wait for the host's name to appear! This app completely follows the rules of the game, including four rounds of actions available (pre-flop, flop, turn, river). Furthermore, the application also automates the assignment of positions such as Dealer, Small Blind, and Big Blind. Also, the application also keeps track of user's chip count and automates the process of chip transferring to the winner of the pot of every hand. Whenever it's a player's turn, a player can make any valid move according to Texas Hold'em rules such as call, raise, fold, check, and also going ALL-IN! Players can also check other players' statistics that are stored persistently on each player's device by using the information icon ride beside each player. Below, we will first demonstrate the app and then go into the implementation details.

## Screenshots Showing a Complete Game Process

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 20 48 34](https://github.com/user-attachments/assets/959e689e-ad8a-4dc6-9bf4-cb34d436bb29)

At first, one player can host a game by hitting Host Game. Every player can also decide how much chips to bring into a game through the slider on top.

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 20 49 28](https://github.com/user-attachments/assets/374748dc-f900-4c07-9aa3-c88c1d5597f0)

After a player starts hosting a game, they then create an empty game room.

![Simulator Screenshot - iPhone 15 Pro Max - 2024-10-01 at 20 49 44](https://github.com/user-attachments/assets/9d4705dd-ec43-42e5-a9b8-f0770429c489)

Other users can hit Search for games to look for any game hosted in the same WiFi network. When the desired game appears, simply click on the name of the host to join the game.

![Simulator Screenshot - iPhone 15 Plus - 2024-10-01 at 20 49 57](https://github.com/user-attachments/assets/1e29ba94-cb5c-4a7e-8c9b-1ca778b579a0)

Here's an example with 3 players in a game!

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 20 50 15](https://github.com/user-attachments/assets/d2d3578f-3a54-43a3-abd1-6f2e7b2cdebd)

The host can then hit Start, which is exclusive only to the host. Starting a hand and selecting a winner of the pot to transfer chips are exclusive to thhe host of the game.
Here, we can also see that the first player to act, Player 1, gets to choose from FOLD, CALL, and RAISE. Notice that the name of player to action will blink on the list of players as shown. This will occur on all devices in the same game to let every player know who's to action.

![Simulator Screenshot - iPhone 15 Plus - 2024-10-01 at 22 17 40](https://github.com/user-attachments/assets/214bace0-8ef7-4e0c-86dd-e0c7586ed9d9)

Player 1 decides to raise to 5, and Player 2 decides to call. Player 3 can now make a decision as the big blind. If Player 3 re-raises, the round of actions will start again and everyone before Player 3 get another turn to make a decision.

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 22 18 33](https://github.com/user-attachments/assets/122001f4-6dc7-425b-a7c2-c22142e7af66)

As shown here, Player 1 gets another round to make a decision because the wager is now 15 but not 5. Player 1 calls, and Player 2 folds. Therefore, for later rounds, only Player 1 and Player 3 remain in game and Player 2 is skipped because Player 2 has folded.

![Simulator Screenshot - iPhone 15 Plus - 2024-10-01 at 22 18 47](https://github.com/user-attachments/assets/75c7f841-4b64-4f82-9463-eeecee044693)

Here, Player 3 is expected to action because Player 2 has folded. Therefore, since small blind has folded, the first to action becomes next position, which is big blind.


![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 22 19 11](https://github.com/user-attachments/assets/10ccc13b-5950-4572-8d1f-d50fdb4a7ae3)

Just for demonstration purpose here, we assume Player 1 and Player 3 just check all the way till the hand ends. The host of the game can now determine who wins the game and selects the winner.

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 22 19 15](https://github.com/user-attachments/assets/d51f15cb-1181-497c-81ab-599487676735)

The host can then select a winner through this menu.

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 22 19 22](https://github.com/user-attachments/assets/7ec27b12-b347-410d-ae45-1a6fb3c3ea3c)

After a winner is selected, notice how all the chip transfers are completed. Also keep in mind that chip counts of each players are updated instantly after a player makes an action to ensure every player in the game has the most up to date information of each player.


## All-In Chip Calculations

![372710509-7f41a97d-2ac5-4af8-a0a6-4b5c0ab35987](https://github.com/user-attachments/assets/4c6fa0f5-e59f-44ab-838a-a536a702e740)

Notice at the start of this game, Player 1 has less chips than Player 2.

![372710629-16c22626-1790-437c-ba68-c8aca91110f0](https://github.com/user-attachments/assets/ffef4c34-df08-4645-a09e-af0a16852ce4)

Here Player 1 and Player 2 both go all-in. Assuming Player 1 wins, Player 1 should not be able to take Player 2's entire stack according to Texas Hold'em Rules.

![372710747-a2b948bf-00b7-4d55-ae99-a82b65095e11](https://github.com/user-attachments/assets/f1df00d5-591a-47ba-935d-6492d37e6989)

Therefore, after choosing Player 1, the app automatically recognizes that Player 1 cannot win the entire pot. The remainder of Player 2's stack can then be returned to Player 2.

![372710930-3d13a8fb-a53d-4d9b-bea4-efd4e473b86b](https://github.com/user-attachments/assets/7c736884-0431-4203-a622-18a90d9e3247)

Just like this, Player 2 gets their 28 back.


## Screenshots Showing Additional Features

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 20 51 19](https://github.com/user-attachments/assets/5111034b-3f96-42d3-85d3-f81b1334a163)

The information icon beside each player in the game can bring up this page of statistics of a player. When playing in a game, each player's statistics is available for other players to view. This statistics is stored locally in each player's device persistently with SwiftData. Whenever a player joins a game, the statistics is sent to the host and then sent to every player in the game through the network connection. Since the statistics is stored locally, a player's statistics can follow the player no matter who the player plays with.

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 20 49 02](https://github.com/user-attachments/assets/c0593481-1263-4b15-91b7-cd88305d9eb7)

A player can also store multiple profiles on their device through modifying the local PlayerRecords. A player can choose which profile to join a game with if the player wants to separate their records from playing with different people.

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 21 30 14](https://github.com/user-attachments/assets/b6c11e7d-4bc8-4c0c-8808-a41377350520)

Here's a menu for extra features on the host's device. When a hand goes wrong, the host can end the hand and disburse the chip in the pot.

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 21 31 02](https://github.com/user-attachments/assets/c06da94d-659c-4de8-9bf6-4a7ff0919608)

When a host ends a game, every player's winning or loss is calculated and shown.

![Simulator Screenshot - iPhone 15 Pro Max - 2024-10-01 at 21 33 02](https://github.com/user-attachments/assets/2e273ba5-0ecb-4c8a-917c-07b4100ec4c7)

Notice a player who is not a host can also choose to leave the game first.

![Simulator Screenshot - iPhone 15 Pro Max - 2024-10-01 at 22 07 00](https://github.com/user-attachments/assets/71f473ea-1b58-499c-b96d-26b3843e24be)

When a player does leave the game first, the player is shown his winning or loss.

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 21 34 28](https://github.com/user-attachments/assets/2a4e40d2-8928-4245-a32b-4da69ee644db)

When the game ends, the player who leaves earlier also has their winning or loss shown.

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 22 12 50](https://github.com/user-attachments/assets/e40cdc95-3dc0-4122-b236-431730efd6fc)

Whenever a mistake is made by selecting the wrong winner of the pot, the host can revert its action by restoring the pot.

![Simulator Screenshot - iPhone 15 Pro - 2024-10-01 at 22 13 16](https://github.com/user-attachments/assets/c7efe0fc-aa60-4398-ba19-182e26c133f6)

After restoring the pot and giving the pot to the correct winner, here's the result.

![Simulator Screenshot - iPhone 15 Pro Max - 2024-10-01 at 22 14 34](https://github.com/user-attachments/assets/0b26a5a1-865c-4453-b24b-5e22597f27f2)

Any player can also acquire additional chips by hitting the buy in option in the menu in the top right corner.




### The app icon is from this following website.
<a href="https://www.flaticon.com/free-icons/poker" title="poker icons">Poker icons created by Freepik - Flaticon</a>
