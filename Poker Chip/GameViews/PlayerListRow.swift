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
            Text(player.position)
            Text(String(player.chip))
        }
    }
}

#Preview {
    PlayerListRow(player: Player(name: "hi", chip: 3, position: "d"), bb: true)
}
