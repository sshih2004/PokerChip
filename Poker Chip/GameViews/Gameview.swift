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
    var body: some View {
        VStack {
            List(gameVar.playerList.playerList) { player in
                PlayerListRow(player: player, bb: true)
            }
            Button("START") {
                serverGameHandling.startGame()
            }
            .disabled(!gameVar.isServer)
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
