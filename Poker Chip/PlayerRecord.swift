//
//  PlayerRecord.swift
//  Poker Chip
//
//  Created by Steven Shih on 7/14/24.
//

import Foundation
import SwiftData

@Model
class PlayerRecord: Codable {
    enum CodingKeys: CodingKey {
        case playerName
        case playerTotalWinnings
        case VPIP
        case PFR
        case AF
        case threeBet
    }
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
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        playerName = try container.decode(String.self, forKey: .playerName)
        playerTotalWinnings = try container.decode(Double.self, forKey: .playerTotalWinnings)
        VPIP = try container.decode(Double.self, forKey: .VPIP)
        PFR = try container.decode(Double.self, forKey: .PFR)
        AF = try container.decode(Double.self, forKey: .AF)
        threeBet = try container.decode(Double.self, forKey: .threeBet)
    }
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(playerName, forKey: .playerName)
        try container.encode(playerTotalWinnings, forKey: .playerTotalWinnings)
        try container.encode(VPIP, forKey: .VPIP)
        try container.encode(PFR, forKey: .PFR)
        try container.encode(AF, forKey: .AF)
        try container.encode(threeBet, forKey: .threeBet)
    }
}
