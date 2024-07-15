//
//  PlayerRecord.swift
//  Poker Chip
//
//  Created by Steven Shih on 7/14/24.
//

import Foundation
import SwiftData

@Model
class PlayerRecord {
    var playerName: String
    var playerTotalWinnings: Double
    var VPIP: Double
    var PFR: Double
    var AF: Double
    var threeBet: Double
    init(playerName: String, playerTotalWinnings: Double = 0.0, VPIP: Double = 0.0, PFR: Double = 0.0, AF: Double = 0.0, threeBet: Double = 0.0, ATS: Double = 0.0) {
        self.playerName = playerName
        self.playerTotalWinnings = playerTotalWinnings
        self.VPIP = VPIP
        self.PFR = PFR
        self.AF = AF
        self.threeBet = threeBet
    }
}
