//
//  EditPlayerRecordView.swift
//  Poker Chip
//
//  Created by Steven Shih on 8/6/24.
//

import SwiftUI
import SwiftData

struct EditPlayerRecordView: View {    
    @Query var playerRecords: [PlayerRecord]
    @Environment(\.modelContext) var modelContext
    var body: some View {
        List {
            ForEach(playerRecords) { playerRecord in
                Text(playerRecord.playerName)
            }
        }
    }
}

#Preview {
    EditPlayerRecordView()
}
