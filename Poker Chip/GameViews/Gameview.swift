//
//  Gameview.swift
//  Poker Chip
//
//  Created by Steven Shih on 6/15/24.
//

import SwiftUI

struct Gameview: View {
    @ObservedObject var gameVar: GameVariables
    @ObservedObject var serverGameHandling: ServerGameHandling
    @State var clientRaising: Double = 1.0
    var client: PeerBrowser?
    @State var raiseAlert: Bool = false
    @State var winner: String = "Select a Winner"
    @State var showBuyIn: Bool = false
    @State var inGameBuyIn: Double = 0.0
    @State var cashOutAlert: Bool = false
    @State var leftPlayerView: Bool = false
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Menu("Options") {
                    Button("Buy In") {
                        // Half Modal
                        self.showBuyIn = true
                    }
                    Button("Cash Out") {
                        cashOutAlert = true
                    }
                    Button("Left Players") {
                        leftPlayerView = true
                    }
                }
                .sheet(isPresented: $leftPlayerView, content: {
                    List(gameVar.leftPlayers.playerList) { player in
                        PlayerListRow(player: player, bb: true)
                    }
                    .presentationDragIndicator(.visible)
                })
                .alert("Cash Out", isPresented: $cashOutAlert, actions: {
                    Button("Leave Game", role: .destructive) {
                        self.client?.sendLeaveGame(playerName: gameVar.name)
                                gameVar.fullScreen = false
                            }
                    Button("Cancel", role: .cancel) {
                        
                    }
                }, message: {
                    Text(String(gameVar.chipCount-gameVar.buyIn))
                })
                .padding()
                .sheet(isPresented: $showBuyIn, content: {
                    VStack {
                        Slider(value: $inGameBuyIn, in: 1...100, step: 0.5)
                            .padding(.top, 50)
                            .frame(height: 200.0)
                        HStack {
                            Spacer()
                            Text(String(self.inGameBuyIn) + " bb")
                                .font(.title)
                            Spacer()
                        }
                        Spacer()
                        Button(action: {
                            if gameVar.isServer {
                                serverGameHandling.handleServerRebuy(rebuy: self.inGameBuyIn)
                            } else {
                                self.client?.sendReBuyIn(rebuy: self.inGameBuyIn)
                            }
                            self.showBuyIn = false
                        }, label: {
                            Text("Buy In")
                                .font(.title2)
                        })
                        .padding()
                    }
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                })
            }
            List(gameVar.playerList.playerList) { player in
                PlayerListRow(player: player, bb: true)
            }
            Spacer()
            Text("Pot: " + String(gameVar.playerList.pot))
            .font(.title2)
            .padding(.bottom, 7)
            if gameVar.isServer {
                HStack {
                    Picker("Choose a winner", selection: $winner) {
                        Text("Select a Winner").tag("Select a Winner")
                        ForEach(gameVar.playerList.playerList, id: \.self) {
                            player in
                            Text(player.name)
                                .tag(player.name)
                        }
                    }
                    .padding(.leading, 15)
                    .disabled(gameVar.selectWinner)
                    .onChange(of: winner) { oldValue, newValue in
                        self.serverGameHandling.handleWinner(winnerName: self.winner)
                        self.winner = "Select a Winner"
                        gameVar.selectWinner = true
                    }
                    Spacer()
                    Button("START") {
                        gameVar.buttonStart = true
                        serverGameHandling.startGame()
                    }
                    .padding(.trailing, 30.0)
                    .disabled(gameVar.buttonStart)
                }
                .padding(.bottom, 8)
                .padding(.trailing, 10)
                .padding(.leading, 13)
            }
            Spacer()
            HStack {
                Spacer()
                Button("FOLD") {
                    if gameVar.isServer {
                        serverGameHandling.serverHandleSelf(action: ClientAction(betSize: 0.0, clientAction: .fold))
                    } else {
                        client?.returnAction(clientAction: ClientAction(betSize: 0, clientAction: .fold))
                    }
                }
                .disabled(gameVar.buttonFold)
                Spacer()
                Button("CHECK") {
                    if gameVar.isServer {
                        serverGameHandling.serverHandleSelf(action: ClientAction(betSize: 0.0, clientAction: .check))
                        
                    } else {
                        client?.returnAction(clientAction: ClientAction(betSize: 0, clientAction: .check))
                    }
                    
                }
                .disabled(gameVar.buttonCheck)
                Spacer()
                Button("CALL") {
                    if gameVar.isServer {
                        serverGameHandling.serverHandleSelf(action: ClientAction(betSize: gameVar.curAction?.betSize ?? 0, clientAction: .call))
                        
                    } else {
                        client?.returnAction(clientAction: ClientAction(betSize: gameVar.curAction?.betSize ?? 0, clientAction: .call))
                    }
                    
                }
                .disabled(gameVar.buttonCall)
                Spacer()
                Button("RAISE") {
                    // TODO: handle raise amount
                    raiseAlert = true
                    
                }
                .disabled(gameVar.buttonRaise)
                .fullScreenCover(isPresented: $raiseAlert, onDismiss: {
                    if gameVar.isServer {
                        serverGameHandling.serverHandleSelf(action: ClientAction(betSize: clientRaising, clientAction: .raise))
                        
                    } else {
                        client?.returnAction(clientAction: ClientAction(betSize: clientRaising, clientAction: .raise))
                    }
                }) {
                    Spacer()
                    Slider(value: $clientRaising, in: (gameVar.curAction?.betSize ?? 1)...gameVar.chipCount, step: 0.5)
                    Text(String(clientRaising))
                    Spacer()
                    Button("Done") {
                        raiseAlert = false
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    Gameview(gameVar: GameVariables(name: "HIHI", chipCount: 100, devices: [String](), isServer: false), serverGameHandling: ServerGameHandling(server: PeerListener(), gameVar: GameVariables(name: "HI", chipCount: 0, devices: [String](), isServer: false)))
}
