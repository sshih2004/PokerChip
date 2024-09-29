//
//  ModifyGameSettingsView.swift
//  Poker Chip
//
//  Created by Steven Shih on 8/1/24.
//

import SwiftUI

struct ModifyGameSettingsView: View {
    @Binding var smallBlind: Double
    @Binding var bigBlind: Double
    @Environment(\.dismiss) var dismiss
    var body: some View {
        List {
            Section("Blinds") {
                HStack {
                    Text("Small Blind: ")
                    TextField("Small Blind", value: $smallBlind, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Big Blind: ")
                    TextField("Big Blind", value: $bigBlind, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            Section {
                HStack {
                    Spacer()
                    Button("Dismiss") {
                        dismiss()
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @State var smallBlindPreview = 0.5
        @State var bigBlindPreview = 1.0
        var body: some View {
            ModifyGameSettingsView(smallBlind: $smallBlindPreview, bigBlind: $bigBlindPreview)
        }
    }
    return Preview()
}
