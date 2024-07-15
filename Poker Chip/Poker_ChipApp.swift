//
//  Poker_ChipApp.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/15/24.
//

import SwiftUI
import SwiftData

@main
struct Poker_ChipApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: PlayerRecord.self)
    }
}
