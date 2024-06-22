//
//  Gameview.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/15/24.
//

import SwiftUI

struct Gameview: View {
    @ObservedObject var gameVar: GameVariables
    var body: some View {
        VStack {
            List(gameVar.playerList.playerList) { player in
                PlayerListRow(player: player, bb: true)
            }
            HStack {
                Spacer()
                Button("FOLD") {
                    
                }
                Spacer()
                Button("CALL") {
                    
                }
                Spacer()
                Button("RAISE") {
                    
                }
                Spacer()
            }
        }
    }
}

#Preview {
    Gameview(gameVar: GameVariables(name: "HIHI", chipCount: 100, devices: [String]()))
}
