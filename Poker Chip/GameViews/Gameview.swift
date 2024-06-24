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
    var client: PeerBrowser?
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
                        serverGameHandling.serverHandleSelf(action: ClientAction(betSize: 0.0, clientAction: .call))
                        
                    } else {
                        client?.returnAction(clientAction: ClientAction(betSize: 0, clientAction: .call))
                    }
                    
                }
                .disabled(gameVar.buttonCall)
                Spacer()
                Button("RAISE") {
                    // TODO: handle raise amount
                    if gameVar.isServer {
                        serverGameHandling.serverHandleSelf(action: ClientAction(betSize: 0.0, clientAction: .raise))
                        
                    } else {
                        client?.returnAction(clientAction: ClientAction(betSize: 0, clientAction: .raise))
                    }
                    
                }
                .disabled(gameVar.buttonRaise)
                Spacer()
            }
        }
    }
}

#Preview {
    Gameview(gameVar: GameVariables(name: "HIHI", chipCount: 100, devices: [String](), isServer: false), serverGameHandling: ServerGameHandling(server: PeerListener(), gameVar: GameVariables(name: "HI", chipCount: 0, devices: [String](), isServer: false)))
}
