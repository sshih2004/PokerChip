//
//  ContentView.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/15/24.
//

import SwiftUI
import Network

struct ContentView: View {
    @ObservedObject var server = PeerListener()
    @State var devices: [String] = [String]()
    @ObservedObject var client = PeerBrowser()
    @ObservedObject var gameVar = GameVariables(name: "", chipCount: 100, devices: [String]())
    @State var hostDisabled: Bool = false
    @State var nameDisabled: Bool = false
    @State var hostFullScreen: Bool = false
    
    var body: some View {
        List {
            Section("HOST GAME") {
                HStack {
                    Text("Your Name")
                    TextField("Name", text: $gameVar.name)
                        .multilineTextAlignment(.trailing)
                        .disabled(nameDisabled)
                }
                Button {
                    gameVar.playerList.playerList.append(Player(name: gameVar.name, chip: 100, position: "Unknown"))
                    server.setVar(gameVar: gameVar)
                    server.startListening()
                    hostDisabled = true
                    nameDisabled = true
                    hostFullScreen = true
                    
                } label: {
                    HStack {
                        Spacer()
                        Text("Host Game")
                        Spacer()
                    }
                }
                .disabled(hostDisabled)
                .fullScreenCover(isPresented: $hostFullScreen, content: {
                    Gameview(gameVar: gameVar)
                })
                Button {
                    server.setVar(gameVar: gameVar)
                    server.stopListening()
                    hostDisabled = false
                    
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
                List(client.results, id: \.self) { result in
                    if case let NWEndpoint.service(name: name, type: _, domain: _, interface: _) = result.endpoint {
                        Button(name) {
                            client.connect(to: result.endpoint)
                            gameVar.fullScreen = true
                            nameDisabled = true
                        }
                        .contentShape(Rectangle())
                        .buttonStyle(BorderlessButtonStyle())
                        .fullScreenCover(isPresented: $gameVar.fullScreen, content: {
                            Gameview(gameVar: gameVar)
                        })
                        
                    }
                    
                }
                .frame(height: 300.0)
            }
            Section("Log Client Message") {
                List(client.messages, id: \.self) { message in
                        Text(message)
                }
                .frame(height: 300.0)
            }
            Section("Log Server Message") {
                List(server.messages, id: \.self) { message in
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
