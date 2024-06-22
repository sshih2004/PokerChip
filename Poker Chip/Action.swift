//
//  Action.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/15/24.
//

import Foundation

struct Action: Codable {
    var playerList: PlayerList
    var betSize: Double
    var optionCall: Bool
    var optionRaise: Bool
    var optionCheck: Bool
    var optionFold: Bool
}
