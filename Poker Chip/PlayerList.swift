//
//  PlayerList.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/15/24.
//

import Foundation

struct PlayerList: Codable {
    var playerList: [Player] = [Player]()
    var pot: Double = 0.0
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
