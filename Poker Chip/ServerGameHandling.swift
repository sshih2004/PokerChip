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
    var bettingSize: Double = 0.0
    var playerIdx: Int = 0
    var lastPlayerIdx: Int
    var countTurn: Int = 0
    var prevPlayerCount: Int = 0
    var raiseAmount: Double = 0.0
    var bettingRound: Int = 5
    var dealerIdx: Int = 0
    var smallBlind: Double = 1.0
    var bigBlind: Double = 2.0
    init(server: PeerListener, gameVar: GameVariables) {
        self.server = server
        self.gameVar = gameVar
        lastPlayerIdx = gameVar.playerList.playerList.count
    }
    // TODO: Figure out showing position, BUY IN, POSITION NAME
    
    func fillPositionThree() {
        var idx: Int = dealerIdx
        for i in 0...2 {
            gameVar.playerList.playerList[idx].position = threePlayer[i]
            if i == 1 {
                gameVar.playerList.playerList[idx].raiseSize = smallBlind
                gameVar.playerList.playerList[idx].chip -= smallBlind
                gameVar.playerList.playerList[idx].actionStr = "Small Blind: " + String(smallBlind)
            }
            if i == 2 {
                gameVar.playerList.playerList[idx].raiseSize = bigBlind
                gameVar.playerList.playerList[idx].chip -= bigBlind
                gameVar.playerList.playerList[idx].actionStr = "Big Blind: " + String(bigBlind)
            }
            idx += 1
            idx %= self.gameVar.playerList.playerList.count
        }
        gameVar.pot += smallBlind + bigBlind
        gameVar.playerList.pot = gameVar.pot
    }
    func startGame() {
        for i in 0...gameVar.playerList.playerList.count - 1 {
            gameVar.playerList.playerList[i].fold = false
            gameVar.playerList.playerList[i].raiseSize = 0.0
            gameVar.playerList.playerList[i].actionStr = ""
            gameVar.playerList.playerList[i].position = ""
        }
        gameVar.pot = 0.0
        prevPlayerCount = 0
        if gameVar.playerList.playerList.count >= 3 {
            fillPositionThree()
            self.serverHandleClient(action: ClientAction(betSize: 0, clientAction: .pending))
        }
    }
    
    
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
            if !player.fold {
                cntPlayingPlayer += 1
            }
        }
        return cntPlayingPlayer
    }
    func serverHandleClient(action: ClientAction) {
        print(playerIdx)
        gameVar.buttonCall = true
        gameVar.buttonRaise = true
        gameVar.buttonCheck = true
        gameVar.buttonFold = true
        switch action.clientAction {
        case .call:
            self.gameVar.playerList.playerList[playerIdx].chip = self.gameVar.playerList.playerList[playerIdx].chip - self.bettingSize + self.gameVar.playerList.playerList[playerIdx].raiseSize
            self.gameVar.pot = self.gameVar.pot + self.bettingSize - self.gameVar.playerList.playerList[playerIdx].raiseSize
            self.gameVar.playerList.playerList[playerIdx].raiseSize = self.bettingSize + self.gameVar.playerList.playerList[playerIdx].raiseSize
            self.gameVar.playerList.playerList[playerIdx].actionStr = "Called " + String(self.bettingSize)
        case .raise:
            // TODO: Check for raise size
            self.gameVar.playerList.playerList[playerIdx].chip = self.gameVar.playerList.playerList[playerIdx].chip - action.betSize + self.gameVar.playerList.playerList[playerIdx].raiseSize
            // TODO: DOUBLE Check pot calculation
            self.gameVar.pot = self.gameVar.pot + action.betSize - self.gameVar.playerList.playerList[playerIdx].raiseSize
            countTurn += prevPlayerCount
            prevPlayerCount = 0
            raiseAmount = action.betSize - bettingSize
            bettingSize = action.betSize
            self.gameVar.playerList.playerList[playerIdx].raiseSize += bettingSize
            self.gameVar.playerList.playerList[playerIdx].actionStr = "Raised " + String(self.bettingSize)
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
        if countTurn == 0 {
            bettingRound -= 1
            print("HI:" + String(bettingRound))
            if bettingRound > 0 {
                countTurn = countPlayingPlayer()
                if countTurn == 1 {
                    countTurn = 0
                    bettingRound = 5
                    gameVar.selectWinner = false
                    dealerIdx += 1
                    dealerIdx %= self.gameVar.playerList.playerList.count
                    return
                }
                playerIdx = dealerIdx + 1
                if bettingRound >= 4 {
                    playerIdx += 2
                }
                playerIdx %= self.gameVar.playerList.playerList.count
                prevPlayerCount = 0
                bettingSize = bettingRound >= 4 ? (bigBlind) : 0.0
                for i in 0...gameVar.playerList.playerList.count - 1 {
                    if !gameVar.playerList.playerList[i].fold {
                        if bettingRound < 4 {
                            gameVar.playerList.playerList[i].actionStr = ""
                        }
                    }
                    if bettingRound < 4 {
                        gameVar.playerList.playerList[i].raiseSize = 0.0
                    }
                }
                self.serverHandleClient(action: ClientAction(betSize: 0, clientAction: .pending))
            } else {
                bettingRound = 5
                gameVar.selectWinner = false
                dealerIdx += 1
                dealerIdx %= self.gameVar.playerList.playerList.count
            }
            return
        }
        if gameVar.playerList.playerList[playerIdx].fold {
            playerIdx += 1
            playerIdx %= self.gameVar.playerList.playerList.count
        }
        if playerIdx != 0 {
            server.requestAction(idx: playerIdx - 1, action: Action(playerList: gameVar.playerList, betSize: bettingSize, optionCall: bettingSize == self.gameVar.playerList.playerList[playerIdx].raiseSize, optionRaise: false, optionCheck: bettingSize != self.gameVar.playerList.playerList[playerIdx].raiseSize, optionFold: false))
        } else {
            self.handleServerAction(action: Action(playerList: gameVar.playerList, betSize: bettingSize, optionCall: bettingSize == self.gameVar.playerList.playerList[playerIdx].raiseSize, optionRaise: false, optionCheck: bettingSize != self.gameVar.playerList.playerList[playerIdx].raiseSize, optionFold: false))
        }
    }
    
    func serverHandleSelf(action: ClientAction) {
        serverHandleClient(action: action)
    }
    
    func handleWinner(winnerName: String) {
        for i in 0...gameVar.playerList.playerList.count-1 {
            if gameVar.playerList.playerList[i].name == winnerName {
                gameVar.playerList.playerList[i].chip += gameVar.pot
                gameVar.pot = 0.0
                gameVar.playerList.pot = gameVar.pot
                for i in 0...gameVar.playerList.playerList.count - 1 {
                    gameVar.playerList.playerList[i].actionStr = ""
                }
                server.sendPlayerList()
                gameVar.buttonStart = false
                break
            }
        }
    }
    
}
