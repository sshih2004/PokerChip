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
    var body: some View {
        VStack {
            // TODO: Figure out how to show action
            List(gameVar.playerList.playerList) { player in
                PlayerListRow(player: player, bb: true)
            }
            Spacer()
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
                    .disabled(gameVar.selectWinner)
                    .padding(.leading, 5.0)
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
            }
            Text("Pot: " + String(gameVar.playerList.pot
                                 ))
                .font(.title2)
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
