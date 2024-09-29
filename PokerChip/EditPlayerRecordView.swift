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
    @Environment(\.dismiss) var dismiss
    @State private var path = [PlayerRecord]()
    
    var body: some View {
        NavigationStack(path: $path) {
            List(playerRecords) { playerRecord in
                NavigationLink(value: playerRecord) {
                    Text(playerRecord.playerName)
                }
            }
            .navigationDestination(for: PlayerRecord.self, destination: EditPlayerRecordItemView.init)
            .navigationTitle("PlayerRecords")
            .toolbar(content: {
                HStack {
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                }
            })
        }
    }
}

struct EditPlayerRecordItemView: View {
    @Bindable var playerRecord: PlayerRecord
    var body: some View {
        VStack {
            Form {
                TextField("Player Name Cannot Be Empty", text: $playerRecord.playerName)
            }
            .navigationBarBackButtonHidden(playerRecord.playerName.isEmpty)
        }
    }
        
}

#Preview {
    EditPlayerRecordView()
}
