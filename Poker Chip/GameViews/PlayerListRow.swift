//
//  PlayerListRow.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/15/24.
//

import SwiftUI

struct PlayerListRow: View {
    var player: Player
    var bb: Bool
    var body: some View {
        VStack {
            HStack {
                Text(player.name)
                Text(player.position)
                Text("Chip: " + String(player.chip))
                //Text("Buy in: " + String(player.buyIn))
            }
            if !player.actionStr.isEmpty {
                HStack {
                    Text("Action: ")
                    Text(player.actionStr)
                }
            }
        }
    }
}

#Preview {
    PlayerListRow(player: Player(name: "hi", chip: 30, position: "Dealer"), bb: true)
}
