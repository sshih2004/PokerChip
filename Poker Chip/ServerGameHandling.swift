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
    var bettingRound: Int = 4
    init(server: PeerListener, gameVar: GameVariables) {
        self.server = server
        self.gameVar = gameVar
        lastPlayerIdx = gameVar.playerList.playerList.count
    }
    // TODO: Figure out showing position
    func startGame() {
        for i in 0...gameVar.playerList.playerList.count - 1 {
            gameVar.playerList.playerList[i].fold = false
        }
        playerIdx = 0
        prevPlayerCount = 0
        bettingSize = 0.0
        for i in 0...gameVar.playerList.playerList.count - 1 {
            gameVar.playerList.playerList[i].raiseSize = 0.0
        }
        if gameVar.playerList.playerList.count == 3 {
            countTurn = countPlayingPlayer()
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
        gameVar.buttonCall = true
        gameVar.buttonRaise = true
        gameVar.buttonCheck = true
        gameVar.buttonFold = true
        switch action.clientAction {
        case .call:
            self.gameVar.playerList.playerList[playerIdx].chip = self.gameVar.playerList.playerList[playerIdx].chip - self.bettingSize + self.gameVar.playerList.playerList[playerIdx].raiseSize
            self.gameVar.playerList.playerList[playerIdx].raiseSize = self.bettingSize + self.gameVar.playerList.playerList[playerIdx].raiseSize
        case .raise:
            // TODO: Check for raise size
            self.gameVar.playerList.playerList[playerIdx].chip -= action.betSize
            countTurn += prevPlayerCount
            prevPlayerCount = 0
            raiseAmount = action.betSize - bettingSize
            bettingSize = action.betSize
            self.gameVar.playerList.playerList[playerIdx].raiseSize = bettingSize
        case .check:
            break
        case .fold:
            self.gameVar.playerList.playerList[playerIdx].fold = true
        case .pending:
            prevPlayerCount -= 1
            playerIdx -= 1
            countTurn += 1
        }
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
                playerIdx = 0
                prevPlayerCount = 0
                bettingSize = 0.0
                for i in 0...gameVar.playerList.playerList.count - 1 {
                    gameVar.playerList.playerList[i].raiseSize = 0.0
                }
                self.serverHandleClient(action: ClientAction(betSize: 0, clientAction: .pending))
            } else {
                bettingRound = 4
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
    
}
