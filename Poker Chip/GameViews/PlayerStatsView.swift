//
//  PlayerStatsView.swift
//  Poker Chip
//
//  Created by Steven Shih on 7/18/24.
//

import SwiftUI

struct PlayerStatsView: View {
    @State var playerRecord: PlayerRecord?
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        let unavailableStr: String = "Unavailable"
        let VPIPValue: Double = (playerRecord?.VPIP ?? 0.0) / (playerRecord?.handCount ?? 1.0)
        let AFValue: Double = (Double(playerRecord?.raiseCount ?? 0)) / (Double(playerRecord?.callCount ?? 1))
        let PFRValue: Double = (playerRecord?.PFR ?? 0.0) / (playerRecord?.handCount ?? 1.0)
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                Group {
                    Text("Name")
                    Text("\(playerRecord?.playerName ?? unavailableStr )")
                    Text("VPIP")
                    Text("\(VPIPValue)")
                    Text("PFR")
                    Text("\(PFRValue)")
                    Text("AF")
                    Text("\(AFValue)")
                    Text("Hand Count")
                    Text("\(playerRecord?.handCount ?? 0.0)")
                    Text("Total Winning")
                    Text("\(playerRecord?.playerTotalWinnings ?? 0.0)")
                }
                .font(.title2)
                .padding()
            }
            .padding()
        }
    }
}

#Preview {
    PlayerStatsView()
}
