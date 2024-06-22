//
//  GameVariables.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/16/24.
//

import Foundation

class GameVariables: ObservableObject {
    @Published var name: String
    @Published var devices: [String]
    @Published var playerList: PlayerList?
    init(name: String, devices: [String]) {
        self.name = name
        self.devices = devices
    }
}
