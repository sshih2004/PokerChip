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
    @Published var playerList: PlayerList = PlayerList()
    @Published var fullScreen: Bool = false
    init(name: String, chipCount: Int, devices: [String]) {
        self.name = name
        self.chipCount = chipCount
        self.devices = devices
    }
}
