//
//  ContentView.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/15/24.
//

import SwiftUI
import Network
import SwiftData

struct ContentView: View {
    @Query var playerRecords: [PlayerRecord]
    @Environment(\.modelContext) var modelContext
    @ObservedObject var server = PeerListener()
    @State var devices: [String] = [String]()
    @ObservedObject var client = PeerBrowser()
    @ObservedObject var gameVar = GameVariables(name: "", chipCount: 100, devices: [String](), isServer: false)
    @State var nameDisabled: Bool = false
    @State var searchDisabled: Bool = false
    @State var searchGameStr: String = "Search for games"
    @State var hostGameAlert = false
    @State var debugNetworkMessage = false
    @State var inputName: String = ""
    @AppStorage("PrevName") var selectionPlayer: String = ""
    let defaults = UserDefaults.standard
    
    var body: some View {
        List {
            Section("BUY IN") {
                Slider(value: $gameVar.buyIn, in: 1...100, step: 0.5)
                HStack {
                    Spacer()
                    Text(String(gameVar.buyIn) + " bb")
                    Spacer()
                }
            }
            Section("YOUR NAME") {
                Picker(selection: $selectionPlayer) {
                    if selectionPlayer.isEmpty {
                        Text("").tag("")
                    }
                    ForEach(playerRecords) {
                        playerRecord in
                        Text(playerRecord.playerName)
                            .tag(playerRecord.playerName)
                    }
                } label: {
                    Text("Select Your Name")
                }
                .onChange(of: selectionPlayer, { oldValue, newValue in
                        defaults.set(selectionPlayer, forKey: "PrevName")
                })

                HStack {
                    Text("Add New Name")
                    TextField("Name", text: $inputName)
                        .multilineTextAlignment(.trailing)
                        .disabled(nameDisabled)
                }
                HStack {
                    Spacer()
                    Button("Add") {
                        if inputName.isEmpty {
                            hostGameAlert = true
                            return
                        }
                        modelContext.insert(PlayerRecord(playerName: inputName))
                        self.selectionPlayer = self.inputName
                        defaults.set(self.selectionPlayer, forKey: "PrevName")
                    }
                    Spacer()
                }
            }
            Section("HOST GAME") {
                Button {
                    gameVar.name = selectionPlayer
                    if gameVar.name.isEmpty {
                        hostGameAlert = true
                        return
                    }
                    var playerToSend: PlayerRecord = PlayerRecord(playerName: "INVALID")
                    for playerRecord in playerRecords {
                        // TODO: Find player and send, figure out updating
                        if playerRecord.playerName == selectionPlayer {
                            playerToSend = playerRecord
                        }
                    }
                    gameVar.playerList.playerList.append(Player(name: gameVar.name, chip: gameVar.buyIn, playerRecord: playerToSend, buyIn: gameVar.buyIn))
                    gameVar.chipCount = gameVar.buyIn
                    server.setVar(gameVar: gameVar)
                    server.serverGameHandling = ServerGameHandling(server: self.server, gameVar: gameVar)
                    server.startListening()
                    gameVar.hostDisabled = true
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
                .disabled(gameVar.hostDisabled)
                Button {
                    server.setVar(gameVar: gameVar)
                    server.stopListening()
                    gameVar.hostDisabled = false
                    
                } label: {
                    HStack {
                        Spacer()
                        Text("Stop Hosting")
                        Spacer()
                    }
                }
                .disabled(!gameVar.hostDisabled)
            }
            Section("JOIN GAME") {
                VStack {
                    Button {
                        gameVar.name = selectionPlayer
                        if gameVar.name.isEmpty {
                            hostGameAlert = true
                            return
                        }
                        client.setVar(gameVar: gameVar)
                        client.startBrowsing()
                        searchDisabled = true
                    } label: {
                        HStack {
                            Spacer()
                            Text(searchDisabled ? "Searching..." : "Search for games" )
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
                            var playerToSend: PlayerRecord = PlayerRecord(playerName: "INVALID")
                            for playerRecord in playerRecords {
                                // TODO: Find player and send, figure out updating
                                if playerRecord.playerName == selectionPlayer {
                                    playerToSend = playerRecord
                                }
                            }
                            client.playerRecord = playerToSend
                            client.connect(to: result.endpoint)
                            searchDisabled = false
                            client.results.removeAll()
                            gameVar.fullScreen = true
                            nameDisabled = true
                        }
                        .contentShape(Rectangle())
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    
                }
                .frame(height: 300.0)
            }
            if debugNetworkMessage {
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
        .fullScreenCover(isPresented: $gameVar.fullScreen, content: {
            Gameview(gameVar: gameVar, serverGameHandling: server.serverGameHandling ?? ServerGameHandling(server: server, gameVar: gameVar), client: client)
        })
        .fullScreenCover(isPresented: $gameVar.cashOutFullScreen, content: {
            CashOutView(gameVar: self.gameVar)
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
