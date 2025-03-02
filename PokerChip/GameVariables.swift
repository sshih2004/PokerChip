//
//  GameVariables.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/16/24.
//

import Foundation

class GameVariables: ObservableObject {
    @Published var name: String
    @Published var chipCount: Decimal
    @Published var devices: [String]
    @Published var isServer: Bool
    @Published var playerList: PlayerList = PlayerList()
    @Published var fullScreen: Bool = false
    @Published var actionTurn: Bool = true
    @Published var buttonFold: Bool = true
    @Published var buttonCheck: Bool = true
    @Published var buttonCall: Bool = true
    @Published var buttonRaise: Bool = true
    @Published var selectWinner: Bool = true
    @Published var undoPot: Bool = false
    @Published var buttonStart: Bool = false
    @Published var buyIn: Double = 100.0
    @Published var buyInValue: Double = 100.0
    @Published var leftPlayers: PlayerList = PlayerList()
    @Published var remainingPotAlert: Bool = false
    @Published var cashOutAlert: Bool = false
    @Published var forceCashOutAlert: Bool = false
    @Published var cashOutFullScreen: Bool = false
    @Published var inGame: Bool = false
    @Published var hostDisabled: Bool = false
    @Published var invalidPlayerAlert: Bool = false
    @Published var invalidPlayerNameClientAlert: Bool = false
    var pending: Bool = false
    //let pendingCondition = NSCondition()
    var curAction: Action?
    var pot: Decimal = 0.0
    var potReset: Decimal = 0.0
    var bigBlind: Decimal
    init(name: String, chipCount: Decimal, devices: [String], isServer: Bool, bigBlind: Decimal = 2.0) {
        self.name = name
        self.chipCount = chipCount
        self.devices = devices
        self.isServer = isServer
        self.bigBlind = bigBlind
    }
}
