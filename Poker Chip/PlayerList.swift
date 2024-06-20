//
//  PlayerList.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/15/24.
//

import Foundation

struct PlayerList: Codable {
    var playerList: [Player] = [Player]()
    func data() -> Data? {
        try? JSONEncoder().encode(self)
        // hi
    }
}
