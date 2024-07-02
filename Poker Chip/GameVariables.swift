//
//  GameVariables.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/16/24.
//

import Foundation

class GameVariables: ObservableObject {
    @Published var name: String
    @Published var chipCount: Double
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
    @Published var buttonStart: Bool = false
    var pending: Bool = false
    let pendingCondition = NSCondition()
    var curAction: Action?
    var pot: Double = 0.0
    init(name: String, chipCount: Double, devices: [String], isServer: Bool) {
        self.name = name
        self.chipCount = chipCount
        self.devices = devices
        self.isServer = isServer
    }
}
