//
//  GameVariables.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/16/24.
//

import Foundation

class GameVariables: ObservableObject {
    @Published var name: String
    @Published var chipCount: Int
    @Published var devices: [String]
    @Published var isServer: Bool
    @Published var playerList: PlayerList = PlayerList()
    @Published var fullScreen: Bool = false
    @Published var actionTurn: Bool = false
    @Published var buttonFold: Bool = false
    @Published var buttonCheck: Bool = false
    @Published var buttonCall: Bool = false
    @Published var buttonRaise: Bool = false
    init(name: String, chipCount: Int, devices: [String], isServer: Bool) {
        self.name = name
        self.chipCount = chipCount
        self.devices = devices
        self.isServer = isServer
    }
}
