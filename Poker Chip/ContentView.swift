//
//  ContentView.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/15/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var server = PeerListener()
    @State var devices: [String] = [String]()
    @ObservedObject var client = PeerBrowser()
    @ObservedObject var gameVar = GameVariables(name: "", devices: [String]())
    @State var hostDisabled: Bool = false
    
    var body: some View {
        List {
            Section("HOST GAME") {
                HStack {
                    Text("Your Name")
                    TextField("Name", text: $gameVar.name)
                        .multilineTextAlignment(.trailing)
                }
                Button {
                    server.setVar(gameVar: gameVar)
                    server.startListening()
                    hostDisabled = true
                    
                } label: {
                    HStack {
                        Spacer()
                        Text("Host Game")
                        Spacer()
                    }
                }
                .disabled(hostDisabled)
                Button {
                    server.setVar(gameVar: gameVar)
                    server.startListening()
                    hostDisabled = true
                    
                } label: {
                    HStack {
                        Spacer()
                        Text("Stop Hosting")
                        Spacer()
                    }
                }
                .disabled(!hostDisabled)
            }
            Section("JOIN GAME") {
                VStack {
                    Button {
                        client.setVar(gameVar: gameVar)
                        client.startBrowsing()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Search for games")
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
            Section("NEARBY DEVICES") {
                List(gameVar.devices, id: \.self) { device in
                    Button(device) {
                        
                    }
                }
                .frame(height: 300.0)
            }
            Section("Log Message") {
                List(client.messages, id: \.self) { message in
                        Text(message)
                }
                .frame(height: 300.0)
            }
        }
    }
}

#Preview {
    ContentView()
}
