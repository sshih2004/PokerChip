//
//  ClientAction.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/22/24.
//

import Foundation

struct ClientAction: Codable {
    var betSize: Double
    var clientAction: avaiAction
    enum avaiAction: String, Codable {
        case call = "call"
        case raise = "raise"
        case check = "check"
        case fold = "fold"
        case pending = "pending"
    }
}
