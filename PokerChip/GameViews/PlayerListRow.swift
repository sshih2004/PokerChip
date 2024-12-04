//
//  PlayerListRow.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/15/24.
//

import SwiftUI

struct PlayerListRow: View {
    var player: Player
    @State var popUpEnable: Bool = false
    @State var animationEnable: Bool = false
    var body: some View {
        VStack {
            HStack {
                Text(player.name)
                    .frame(width: 55, alignment: .leading)
                Text("Chip: " + String(describing: player.chip))
                    .frame(width: 100, alignment: .leading)
                Spacer()
                Text(player.position)
                    .frame(width: 50, alignment: .trailing)
                //Text("Buy in: " + String(player.buyIn))
                Button(action: {
                    popUpEnable = true
                }, label: {
                    Image(systemName: "info.circle")
                })
                .popover(isPresented: $popUpEnable, content: {
                    PlayerStatsView(playerRecord: player.playerRecord)
                })
            }
            if !player.actionStr.isEmpty {
                HStack {
                    Spacer()
                    Text(player.actionStr)
                        .frame(width: 150, alignment: .trailing)
                        .padding(.trailing, 30)
                }
                .fontWeight(.bold)
                .padding(.top, 15)
            }
        }
        .opacity(player.curPlayerAnimation ? (animationEnable ? 1.0 : 0.0) : 1.0)
        .animation(.easeOut(duration: 1).repeatForever(), value: animationEnable)
        .onAppear(perform: {
            withAnimation {
                animationEnable = true
            }
        })
    }
}

#Preview {
    PlayerListRow(player: Player(name: "hi", chip: 30, position: "Dealer"))
}
