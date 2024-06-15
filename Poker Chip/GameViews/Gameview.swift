//
//  Gameview.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/15/24.
//

import SwiftUI

struct Gameview: View {
    @State var players:[Player] = [Player(name: "hi", chip: 30, position: "Dealer")]
    var body: some View {
        List(players) { player in
            PlayerListRow(player: player, bb: true)
        }
    }
}

#Preview {
    Gameview()
}
