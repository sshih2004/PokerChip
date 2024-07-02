//
//  Player.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/15/24.
//

import Foundation


struct Player: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var chip: Double
    var position: String = ""
    var fold: Bool = false
    var raiseSize: Double = 0.0
    var actionStr: String = ""
}
