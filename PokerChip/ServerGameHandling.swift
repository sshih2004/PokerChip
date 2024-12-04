//
//  ServerGameHandling.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/22/24.
//

import Foundation

class ServerGameHandling: ObservableObject {
    var server: PeerListener
    var gameVar: GameVariables
    var threePlayer: [String] = ["D", "SB", "BB"]
    var bettingSize: Decimal = 0.0
    var playerIdx: Int = 0
    var lastPlayerIdx: Int
    var countTurn: Int = 0
    var prevPlayerCount: Int = 0
    var raiseAmount: Decimal = 0.0
    var bettingRound: Int = 5
    var dealerIdx: Int = 0
    var smallBlind: Decimal
    var bigBlind: Decimal
    init(server: PeerListener, gameVar: GameVariables, smallBlind: Decimal = 1.0, bigBlind: Decimal = 2.0) {
        self.server = server
        self.gameVar = gameVar
        lastPlayerIdx = gameVar.playerList.playerList.count
        self.smallBlind = smallBlind
        self.bigBlind = bigBlind
    }
    
    // This function sets the Dealer, SB, BB and take SB, BB chips away from corresponding players
    func fillPositionThree() {
        var idx: Int = dealerIdx
        for i in 0...2 {
            gameVar.playerList.playerList[idx].position = threePlayer[i]
            if i == 1 {
                gameVar.playerList.playerList[idx].raiseSize = smallBlind
                gameVar.playerList.playerList[idx].chip -= smallBlind
                gameVar.playerList.playerList[idx].actionStr = "Small Blind: " + String(describing: smallBlind)
            }
            if i == 2 {
                gameVar.playerList.playerList[idx].raiseSize = bigBlind
                gameVar.playerList.playerList[idx].chip -= bigBlind
                gameVar.playerList.playerList[idx].actionStr = "Big Blind: " + String(describing: bigBlind)
            }
            idx += 1
            idx %= self.gameVar.playerList.playerList.count
        }
        gameVar.pot += smallBlind + bigBlind
        gameVar.playerList.pot = gameVar.pot
    }
    
    // starts a game and checks if every player is eligible
    func startGame() {
        // check if every player is eligible
        for i in 0...gameVar.playerList.playerList.count - 1 {
            if gameVar.playerList.playerList[i].chip <= 0 {
                gameVar.invalidPlayerAlert = true
                gameVar.buttonStart = false
                return
            }
        }
        // only start a game if there are enough people for D, SB, BB
        if gameVar.playerList.playerList.count >= 3 {
            gameVar.undoPot = false
            gameVar.inGame = true
            for i in 0...gameVar.playerList.playerList.count - 1 {
                gameVar.playerList.playerList[i].fold = false
                gameVar.playerList.playerList[i].potLimit = 0.0
                gameVar.playerList.playerList[i].raiseSize = 0.0
                gameVar.playerList.playerList[i].actionStr = ""
                gameVar.playerList.playerList[i].position = ""
                gameVar.playerList.playerList[i].playerRecord?.handCount += 1
            }
            gameVar.pot = 0.0
            prevPlayerCount = 0
            fillPositionThree()
            self.serverHandleClient(action: ClientAction(betSize: 0, clientAction: .pending))
        } else {
            gameVar.buttonStart = false
        }
    }
    
    // setup server UI
    func handleServerAction(action: Action) {
        gameVar.playerList = action.playerList
        gameVar.buttonCall = action.optionCall
        gameVar.buttonRaise = action.optionRaise
        gameVar.buttonCheck = action.optionCheck
        gameVar.buttonFold = action.optionFold
    }
    
    func countPlayingPlayer() -> Int {
        var cntPlayingPlayer: Int = 0
        for player in gameVar.playerList.playerList {
            if !player.fold && player.chip > 0 {
                cntPlayingPlayer += 1
            }
        }
        return cntPlayingPlayer
    }
    
    // recursive function that simulates the game of Texas Hold'Em
    func serverHandleClient(action: ClientAction) {
        // print(playerIdx)
        self.gameVar.playerList.playerList[playerIdx].curPlayerAnimation = false
        gameVar.buttonCall = true
        gameVar.buttonRaise = true
        gameVar.buttonCheck = true
        gameVar.buttonFold = true
        switch action.clientAction {
        case .call:
            if self.gameVar.playerList.playerList[playerIdx].chip + self.gameVar.playerList.playerList[playerIdx].raiseSize < self.bettingSize {
                self.gameVar.pot += self.gameVar.playerList.playerList[playerIdx].chip
                self.gameVar.playerList.playerList[playerIdx].raiseSize = self.gameVar.playerList.playerList[playerIdx].chip
                self.gameVar.playerList.playerList[playerIdx].actionStr = "Called ALL IN"
                self.gameVar.playerList.playerList[playerIdx].chip = 0
            } else {
                self.gameVar.playerList.playerList[playerIdx].chip = self.gameVar.playerList.playerList[playerIdx].chip - self.bettingSize + self.gameVar.playerList.playerList[playerIdx].raiseSize
                self.gameVar.pot = self.gameVar.pot + self.bettingSize - self.gameVar.playerList.playerList[playerIdx].raiseSize
                self.gameVar.playerList.playerList[playerIdx].raiseSize = self.bettingSize
                self.gameVar.playerList.playerList[playerIdx].actionStr = "Called " + String(describing: self.bettingSize)
                self.gameVar.playerList.playerList[playerIdx].playerRecord?.callCount += 1
            }
            if bettingRound >= 4 {
                self.gameVar.playerList.playerList[playerIdx].VPIPCurRound = true
            }
        case .raise:
            // TODO: Check for raise size
            self.gameVar.playerList.playerList[playerIdx].chip = self.gameVar.playerList.playerList[playerIdx].chip - action.betSize + self.gameVar.playerList.playerList[playerIdx].raiseSize
            self.gameVar.pot = self.gameVar.pot + action.betSize - self.gameVar.playerList.playerList[playerIdx].raiseSize
            countTurn += prevPlayerCount
            prevPlayerCount = 0
            raiseAmount = action.betSize - bettingSize
            bettingSize = action.betSize
            self.gameVar.playerList.playerList[playerIdx].raiseSize = bettingSize
            self.gameVar.playerList.playerList[playerIdx].actionStr = "Raised " + String(describing: self.bettingSize)
            self.gameVar.playerList.playerList[playerIdx].playerRecord?.raiseCount += 1
            if bettingRound >= 4 {
                self.gameVar.playerList.playerList[playerIdx].PFRCurRound = true
                self.gameVar.playerList.playerList[playerIdx].VPIPCurRound = true
            }
        case .check:
            self.gameVar.playerList.playerList[playerIdx].actionStr = "Checked"
        case .fold:
            self.gameVar.playerList.playerList[playerIdx].fold = true
            self.gameVar.playerList.playerList[playerIdx].actionStr = "Fold"
            prevPlayerCount -= 1
        case .pending:
            prevPlayerCount -= 1
            playerIdx -= 1
            countTurn += 1
        }
        gameVar.playerList.pot = gameVar.pot
        prevPlayerCount += 1
        playerIdx += 1
        playerIdx %= self.gameVar.playerList.playerList.count
        countTurn -= 1
        self.server.sendPlayerList()
        if countTurn <= 0 {
            bettingRound -= 1
            if bettingRound > 0 {
                countTurn = countPlayingPlayer()
                if countTurn == 1 {
                    if bettingRound < 4 {
                        for i in 0...gameVar.playerList.playerList.count - 1 {
                            gameVar.playerList.playerList[i].potLimit += gameVar.playerList.playerList[i].raiseSize
                            gameVar.playerList.playerList[i].raiseSize = 0.0
                        }
                    }
                    countTurn = 0
                    bettingRound = 5
                    gameVar.selectWinner = false
                    dealerIdx += 1
                    dealerIdx %= self.gameVar.playerList.playerList.count
                    return
                }
                playerIdx = dealerIdx + 1
                playerIdx %= self.gameVar.playerList.playerList.count
                for _ in 0...gameVar.playerList.playerList.count - 1 {
                    if !gameVar.playerList.playerList[playerIdx].fold {
                        break
                    }
                    playerIdx += 1
                    playerIdx %= self.gameVar.playerList.playerList.count
                }
                // Preflop action starts with UTG
                if bettingRound >= 4 {
                    playerIdx += 2
                }
                playerIdx %= self.gameVar.playerList.playerList.count
                prevPlayerCount = 0
                // default bet size for preflop is 1bb
                bettingSize = bettingRound >= 4 ? bigBlind : 0.0
                for i in 0...gameVar.playerList.playerList.count - 1 {
                    if !gameVar.playerList.playerList[i].fold {
                        if bettingRound < 4 {
                            gameVar.playerList.playerList[i].actionStr = ""
                        }
                    }
                    // handle each player's pot contribution to determine if there's side pot
                    if bettingRound < 4 {
                        gameVar.playerList.playerList[i].potLimit += gameVar.playerList.playerList[i].raiseSize
                        gameVar.playerList.playerList[i].raiseSize = 0.0
                    }
                }
                // preflop action
                self.serverHandleClient(action: ClientAction(betSize: 0, clientAction: .pending))
            } else {
                bettingRound = 5
                gameVar.selectWinner = false
                dealerIdx += 1
                dealerIdx %= self.gameVar.playerList.playerList.count
            }
            return
        }
        if gameVar.playerList.playerList[playerIdx].fold || gameVar.playerList.playerList[playerIdx].chip <= 0 {
            for _ in 0...gameVar.playerList.playerList.count - 1 {
                if !gameVar.playerList.playerList[playerIdx].fold {
                    break
                }
                playerIdx += 1
                playerIdx %= self.gameVar.playerList.playerList.count
            }
        }
        self.gameVar.playerList.playerList[playerIdx].curPlayerAnimation = true
        server.sendPlayerList()
        // determine to request action from client or self
        if playerIdx != 0 {
            // print("Sent request to " + String(playerIdx))
            server.requestAction(idx: playerIdx - 1, action: Action(playerList: gameVar.playerList, betSize: bettingSize, optionCall: bettingSize == self.gameVar.playerList.playerList[playerIdx].raiseSize, optionRaise: bettingSize >= self.gameVar.playerList.playerList[playerIdx].chip + self.gameVar.playerList.playerList[playerIdx].raiseSize, optionCheck: bettingSize != self.gameVar.playerList.playerList[playerIdx].raiseSize, optionFold: false))
        } else {
            self.handleServerAction(action: Action(playerList: gameVar.playerList, betSize: bettingSize, optionCall: bettingSize == self.gameVar.playerList.playerList[playerIdx].raiseSize, optionRaise: false, optionCheck: bettingSize != self.gameVar.playerList.playerList[playerIdx].raiseSize, optionFold: false))
        }
    }
    
    func serverHandleSelf(action: ClientAction) {
        serverHandleClient(action: action)
    }
    
    func handleWinner(winnerName: String) {
        if gameVar.pot == 0 {
            gameVar.selectWinner = true
            return
        }
        // TODO: Figure out how to restore when pot distributed to >1 people
        gameVar.potReset = gameVar.pot
        gameVar.undoPot = true
        for i in 0...gameVar.playerList.playerList.count-1 {
            if gameVar.playerList.playerList[i].PFRCurRound {
                gameVar.playerList.playerList[i].playerRecord?.PFR += 1
                gameVar.playerList.playerList[i].PFRCurRound = false
            }
            if gameVar.playerList.playerList[i].VPIPCurRound {
                gameVar.playerList.playerList[i].playerRecord?.VPIP += 1
                gameVar.playerList.playerList[i].VPIPCurRound = false
            }
            gameVar.playerList.playerList[i].curRoundWinningReset = 0.0
            gameVar.playerList.playerList[i].curRoundPlayerRecordWinningReset = 0.0
        }
        for i in 0...gameVar.playerList.playerList.count-1 {
            if gameVar.playerList.playerList[i].name == winnerName {
                for j in 0...gameVar.playerList.playerList.count-1 {
                    gameVar.playerList.playerList[i].chip += min(gameVar.playerList.playerList[j].potLimit, gameVar.playerList.playerList[i].potLimit, gameVar.pot)
                    gameVar.playerList.playerList[i].curRoundWinningReset += min(gameVar.playerList.playerList[j].potLimit, gameVar.playerList.playerList[i].potLimit, gameVar.pot)
                    if i != j {
                        gameVar.playerList.playerList[i].curRoundPlayerRecordWinningReset += min(gameVar.playerList.playerList[j].potLimit, gameVar.playerList.playerList[i].potLimit, gameVar.pot)
                        gameVar.playerList.playerList[i].playerRecord?.playerTotalWinnings += min(gameVar.playerList.playerList[j].potLimit, gameVar.playerList.playerList[i].potLimit, gameVar.pot)
                    }
                    gameVar.pot -= min(gameVar.playerList.playerList[j].potLimit, gameVar.playerList.playerList[i].potLimit, gameVar.pot)
                    if gameVar.pot <= 0 {
                        break
                    }
                }
                if gameVar.pot <= 0 {
                    for i in 0...gameVar.playerList.playerList.count - 1 {
                        gameVar.playerList.playerList[i].actionStr = ""
                    }
                    gameVar.selectWinner = true
                    gameVar.buttonStart = false
                    gameVar.inGame = false
                    gameVar.chipCount = gameVar.playerList.playerList[0].chip
                } else {
                    gameVar.remainingPotAlert = true
                }
                gameVar.playerList.pot = gameVar.pot
                server.sendPlayerList()
                break
            }
        }
    }
    
    func resetHandleWinner() {
        gameVar.pot = gameVar.potReset
        gameVar.playerList.pot = gameVar.pot
        for i in 0...gameVar.playerList.playerList.count-1 {
            gameVar.playerList.playerList[i].chip -= gameVar.playerList.playerList[i].curRoundWinningReset
            gameVar.playerList.playerList[i].playerRecord?.playerTotalWinnings -= gameVar.playerList.playerList[i].curRoundPlayerRecordWinningReset
        }
        server.sendPlayerList()
        gameVar.selectWinner = false
    }
    
    func handleServerRebuy(rebuy: Decimal) {
        self.gameVar.playerList.playerList[0].chip += rebuy
        self.gameVar.playerList.playerList[0].buyIn += rebuy
        server.sendPlayerList()
    }
    
    func handleClientRebuy(rebuy: BuyIn) {
        for i in 0...gameVar.playerList.playerList.count-1 {
            if gameVar.playerList.playerList[i].name == rebuy.playerName {
                gameVar.playerList.playerList[i].chip += rebuy.buyIn
                gameVar.playerList.playerList[i].buyIn += rebuy.buyIn
                server.sendPlayerList()
                break
            }
        }
    }
    
    func handleClientLeave(name: String) {
        for i in 0...gameVar.playerList.playerList.count-1 {
            if gameVar.playerList.playerList[i].name == name {
                gameVar.playerList.playerList[i].actionStr = "Cash Out: " + String(describing: (gameVar.playerList.playerList[i].chip - gameVar.playerList.playerList[i].buyIn))
                gameVar.leftPlayers.playerList.append(gameVar.playerList.playerList[i])
                server.sendLeaveGame(idx: i-1, removeFromConnections: true)
                gameVar.playerList.playerList.remove(at: i)
                server.sendPlayerList()
                break
            }
        }
    }
    
    func cashOutAll() {
        for i in 0...gameVar.playerList.playerList.count-1 {
            gameVar.playerList.playerList[i].actionStr = "Cash Out: " + String(describing: (gameVar.playerList.playerList[i].chip - gameVar.playerList.playerList[i].buyIn))
            gameVar.leftPlayers.playerList.append(gameVar.playerList.playerList[i])
        }
        if gameVar.playerList.playerList.count > 1 {
            for i in 1...gameVar.playerList.playerList.count-1 {
                server.sendLeaveGame(idx: i-1, removeFromConnections: false)
            }
        }
        gameVar.forceCashOutAlert = true
    }
    
    func serverEndGame() {
        gameVar.playerList.playerList = [Player]()
        gameVar.fullScreen = false
        gameVar.cashOutFullScreen = true
        server.stopListening()
        gameVar.hostDisabled = false
        countTurn = 0
    }
    
    func serverEndHand() {
        if playerIdx == 0 {
            self.handleServerAction(action: Action(playerList: self.gameVar.playerList, betSize: self.bettingSize, optionCall: true, optionRaise: true, optionCheck: true, optionFold: true))
        } else {
            server.requestAction(idx: playerIdx-1, action: Action(playerList: self.gameVar.playerList, betSize: self.bettingSize, optionCall: true, optionRaise: true, optionCheck: true, optionFold: true))
        }
        countTurn = 0
        bettingRound = 5
        for i in 0...gameVar.playerList.playerList.count-1 {
            gameVar.playerList.playerList[i].chip += gameVar.playerList.playerList[i].potLimit + gameVar.playerList.playerList[i].raiseSize
            gameVar.playerList.playerList[i].actionStr = ""
            gameVar.playerList.playerList[i].curPlayerAnimation = false
        }
        gameVar.buttonStart = false
        gameVar.pot = 0.0
        gameVar.playerList.pot = 0.0
        server.sendPlayerList()
    }
}
