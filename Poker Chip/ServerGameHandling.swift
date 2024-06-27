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
    var bettingSize: Double = 2.0
    var playerIdx: Int = 0
    var lastPlayerIdx: Int
    init(server: PeerListener, gameVar: GameVariables) {
        self.server = server
        self.gameVar = gameVar
        lastPlayerIdx = gameVar.playerList.playerList.count
    }
    func startGame() {
        // TODO: figure out how to simulate round
        // idea: make a game for each number of people?
        // can't find commonality
        // maybe enum?
        // start a hand
        // start a betting round
        // clear results
        playerIdx = 0
        if gameVar.playerList.playerList.count == 3 {
            var player1Idx: Int = 0
            var player2Idx: Int = 1
            var player3Idx: Int = 2
            self.handleServerAction(action: Action(playerList: self.gameVar.playerList, betSize: self.bettingSize, optionCall: false, optionRaise: false, optionCheck: true, optionFold: false))
            
            
        }
    }
    
    
    
    func handleServerAction(action: Action) {
        gameVar.playerList = action.playerList
        gameVar.buttonCall = action.optionCall
        gameVar.buttonRaise = action.optionRaise
        gameVar.buttonCheck = action.optionCheck
        gameVar.buttonFold = action.optionFold
    }
    
    func serverHandleClient(action: ClientAction) {
        self.gameVar.playerList.playerList[playerIdx+1].chip -= action.betSize
        self.server.sendPlayerList()
        playerIdx += 1
        if playerIdx < gameVar.playerList.playerList.count - 1 {
            server.requestAction(idx: playerIdx, action: Action(playerList: gameVar.playerList, betSize: bettingSize, optionCall: false, optionRaise: false, optionCheck: true, optionFold: false))
        }
    }
    
    func serverHandleSelf(action: ClientAction) {
        if action.betSize != self.bettingSize {
            self.bettingSize = action.betSize
        }
        switch action.clientAction {
        case .call:
            gameVar.playerList.playerList[0].chip = gameVar.playerList.playerList[0].chip - self.bettingSize
        case .raise:
            gameVar.playerList.playerList[0].chip = gameVar.playerList.playerList[0].chip - self.bettingSize
        case .check:
            return
        case .fold:
            return
        case .pending:
            return
        }
        gameVar.buttonCall = true
        gameVar.buttonRaise = true
        gameVar.buttonCheck = true
        gameVar.buttonFold = true
        self.server.sendPlayerList()
        server.requestAction(idx: playerIdx, action: Action(playerList: gameVar.playerList, betSize: bettingSize, optionCall: false, optionRaise: false, optionCheck: true, optionFold: false))
    }
    
}
