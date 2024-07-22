//
//  CashOutView.swift
//  Poker Chip
//
//  Created by Steven Shih on 7/21/24.
//

import SwiftUI

struct CashOutView: View {
    var gameVar: GameVariables
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            List(gameVar.leftPlayers.playerList) { player in
                PlayerListRow(player: player, bb: true)
            }
            .toolbar {
                Button("Leave") {
                    gameVar.leftPlayers.playerList.removeAll()
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    CashOutView(gameVar: GameVariables(name: "", chipCount: 0.0, devices: [String](), isServer: false))
}
