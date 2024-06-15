//
//  Player.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/15/24.
//

import Foundation


struct Player: Identifiable {
    var id: UUID = UUID()
    var name: String
    var chip: Int
    var position: String
}
