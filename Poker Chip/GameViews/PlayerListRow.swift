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
        HStack {
            Text(player.name)
            Text("Position: " + player.position)
            Text("Chip: " + String(player.chip))
        }
    }
}

#Preview {
    PlayerListRow(player: Player(name: "hi", chip: 30, position: "Dealer"), bb: true)
}
