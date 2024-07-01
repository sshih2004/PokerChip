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
    @ObservedObject var gameVar = GameVariables(name: "", chipCount: 100, devices: [String](), isServer: false)
    @State var hostDisabled: Bool = false
    @State var nameDisabled: Bool = false
    @State var searchDisabled: Bool = false
    @State var searchGameStr: String = "Search for games"
    @State var hostGameAlert = false
    
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
                    if gameVar.name.isEmpty {
                        hostGameAlert = true
                        return
                    }
                    gameVar.playerList.playerList.append(Player(name: gameVar.name, chip: 100, position: "Unknown"))
                    server.setVar(gameVar: gameVar)
                    server.serverGameHandling = ServerGameHandling(server: self.server, gameVar: gameVar)
                    server.startListening()
                    hostDisabled = true
                    nameDisabled = true
                    gameVar.fullScreen = true
                    gameVar.isServer = true
                    
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
                        if gameVar.name.isEmpty {
                            hostGameAlert = true
                            return
                        }
                        client.setVar(gameVar: gameVar)
                        client.startBrowsing()
                        searchGameStr = "Searching..."
                        searchDisabled = true
                    } label: {
                        HStack {
                            Spacer()
                            Text(searchGameStr)
                            Spacer()
                        }
                    }
                    .disabled(searchDisabled)
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
        .fullScreenCover(isPresented: $gameVar.fullScreen, content: {
            Gameview(gameVar: gameVar, serverGameHandling: server.serverGameHandling ?? ServerGameHandling(server: server, gameVar: gameVar), client: client)
        })
        .alert("Name Required", isPresented: $hostGameAlert) {
            Button("OK", role: .cancel) {
            }
        }
    }
}

#Preview {
    ContentView()
}
