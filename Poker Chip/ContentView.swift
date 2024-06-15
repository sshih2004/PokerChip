//
//  ContentView.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/15/24.
//

import SwiftUI

struct ContentView: View {
    @State var name: String = ""
    var body: some View {
        List {
            Section("HOST GAME") {
                HStack {
                    Text("Your Name")
                    TextField("Name", text: $name)
                        .multilineTextAlignment(.trailing)
                }
                Button {
                    
                } label: {
                    HStack {
                        Spacer()
                        Text("Host Game")
                        Spacer()
                    }
                }
            }
            Section("JOIN GAME") {
                Button {
                    
                } label: {
                    HStack {
                        Spacer()
                        Text("Search for games")
                        Spacer()
                    }
                }

            }
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
