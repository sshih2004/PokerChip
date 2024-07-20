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
        case callCount
        case raiseCount
    }
    var playerName: String
    var playerTotalWinnings: Double
    var VPIP: Double
    var PFR: Double
    var AF: Double
    var handCount: Double
    var callCount: Int
    var raiseCount: Int
    init(playerName: String, playerTotalWinnings: Double = 0.0, VPIP: Double = 0.0, PFR: Double = 0.0, AF: Double = 0.0, threeBet: Double = 0.0, ATS: Double = 0.0, callCount: Int = 0, raiseCount: Int = 0) {
        self.playerName = playerName
        self.playerTotalWinnings = playerTotalWinnings
        self.VPIP = VPIP
        self.PFR = PFR
        self.AF = AF
        self.handCount = threeBet
        self.callCount = callCount
        self.raiseCount = raiseCount
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        playerName = try container.decode(String.self, forKey: .playerName)
        playerTotalWinnings = try container.decode(Double.self, forKey: .playerTotalWinnings)
        VPIP = try container.decode(Double.self, forKey: .VPIP)
        PFR = try container.decode(Double.self, forKey: .PFR)
        AF = try container.decode(Double.self, forKey: .AF)
        handCount = try container.decode(Double.self, forKey: .threeBet)
        callCount = try container.decode(Int.self, forKey: .callCount)
        raiseCount = try container.decode(Int.self, forKey: .raiseCount)
    }
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(playerName, forKey: .playerName)
        try container.encode(playerTotalWinnings, forKey: .playerTotalWinnings)
        try container.encode(VPIP, forKey: .VPIP)
        try container.encode(PFR, forKey: .PFR)
        try container.encode(AF, forKey: .AF)
        try container.encode(handCount, forKey: .threeBet)
        try container.encode(callCount, forKey: .callCount)
        try container.encode(raiseCount, forKey: .raiseCount)
    }
    func update(to playerRecord: PlayerRecord) {
        self.playerTotalWinnings = playerRecord.playerTotalWinnings
        self.AF = playerRecord.AF
        self.PFR = playerRecord.PFR
        self.VPIP = playerRecord.VPIP
        self.handCount = playerRecord.handCount
        self.callCount = playerRecord.callCount
        self.raiseCount = playerRecord.raiseCount
    }
}
