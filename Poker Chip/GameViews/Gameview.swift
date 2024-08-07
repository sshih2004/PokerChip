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
    @State var clientRaising: Double = 2.0
    var client: PeerBrowser?
    @State var raiseAlert: Bool = false
    @State var winner: String = "Select a Winner"
    @State var showBuyIn: Bool = false
    @State var inGameBuyIn: Double = 0.0
    @State var leftPlayerView: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Button() {
                    gameVar.undoPot = false
                    serverGameHandling.resetHandleWinner()
                } label: {
                    Text("Restore Pot")
                }
                .disabled(!gameVar.undoPot)
                .padding()
                .frame(width: 125)
                .opacity(gameVar.undoPot ? 1 : 0)
                Spacer()
                if gameVar.playerList.blinds.count == 2 {
                    Text("Blinds: " + String(describing: gameVar.playerList.blinds[0]) + " / " + String(describing: gameVar.playerList.blinds[1]))
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                }
                Spacer()
                Menu {
                    Button("Buy In") {
                        // Half Modal
                        self.showBuyIn = true
                    }
                    if !gameVar.isServer {
                        Button("Cash Out") {
                            gameVar.cashOutAlert = true
                        }
                    }
                    if gameVar.isServer {
                        Button("Left Players") {
                            leftPlayerView = true
                        }
                        Button("End Current Hand") {
                            serverGameHandling.serverEndHand()
                        }
                        Button("End Game") {
                            serverGameHandling.cashOutAll()
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Options")
                    }
                }
                .sheet(isPresented: $leftPlayerView, content: {
                    List(gameVar.leftPlayers.playerList) { player in
                        PlayerListRow(player: player)
                    }
                    .presentationDragIndicator(.visible)
                })
                .alert("Confirm Leave Game?", isPresented: $gameVar.cashOutAlert, actions: {
                    Button("Leave", role: .destructive) {
                        self.client?.sendLeaveGame(playerName: gameVar.name)
                    }
                    Button("Cancel", role: .cancel) {
                        
                    }
                })
                .alert("Cash Out", isPresented: $gameVar.forceCashOutAlert, actions: {
                    Button("Confirm", role: .cancel) {
                        if gameVar.isServer {
                            serverGameHandling.serverEndGame()
                        } else {
                            self.gameVar.playerList.playerList = [Player]()
                            gameVar.fullScreen = false
                            gameVar.cashOutFullScreen = true
                        }
                    }
                }, message: {
                    Text(String(describing: gameVar.chipCount-Decimal(gameVar.buyInValue)))
                })
                .padding()
                .frame(width: 125)
                .sheet(isPresented: $showBuyIn, content: {
                    VStack {
                        Slider(value: $inGameBuyIn, in: 1...100, step: 0.5)
                            .padding(.top, 50)
                            .frame(height: 200.0)
                        HStack {
                            Spacer()
                            Text(String(self.inGameBuyIn))
                            Text(" bb")
                            Spacer()
                        }
                        .font(.title)
                        Spacer()
                        Button(action: {
                            if gameVar.isServer {
                                serverGameHandling.handleServerRebuy(rebuy: Decimal(self.inGameBuyIn))
                            } else {
                                gameVar.buyIn += self.inGameBuyIn
                                self.client?.sendReBuyIn(rebuy: Decimal(self.inGameBuyIn))
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
            /*
            List(gameVar.playerList.playerList) { player in
                PlayerListRow(player: player, bb: true)
            }*/
            NavigationStack {
                List {
                    ForEach(gameVar.playerList.playerList, id: \.self) { element in
                        HStack {
                            PlayerListRow(player: element)
                            //NavigationLink(value: element.playerRecord) {
                            //}
                            //.frame(width: 100)
                            
                        }
                    }
                    .if(gameVar.isServer && !gameVar.inGame, transform: { view in
                        view.onDelete(perform: { indexSet in
                            for idx in indexSet {
                                serverGameHandling.handleClientLeave(name: gameVar.playerList.playerList[idx].name)
                            }
                        })
                    })
                }
                /*.navigationDestination(for: PlayerRecord.self, destination: { Hashable in
                    Text(Hashable.playerName)
                })*/
            }
            Spacer()
            HStack {
                Text("Pot: " + String(describing: gameVar.playerList.pot))
                    .font(.title2)
                    .padding(.bottom, 7)
            }
            if gameVar.isServer {
                HStack {
                    Picker("Choose a winner", selection: $winner) {
                        Text("Select a Winner").tag("Select a Winner")
                        ForEach(gameVar.playerList.playerList, id: \.self) {
                            player in
                            if !player.fold {
                                Text(player.name)
                                    .tag(player.name)
                            }
                        }
                    }
                    .alert("Remaining Pot", isPresented: $gameVar.remainingPotAlert, actions: {
                        Button("OK", role: .cancel) {
                        }
                    }, message: {
                        Text("Select Next Winner")
                    })
                    .disabled(gameVar.selectWinner)
                    .padding(.leading, 15)
                    .onChange(of: winner) {
                        self.serverGameHandling.handleWinner(winnerName: self.winner)
                        self.winner = "Select a Winner"
                    }
                    Spacer()
                    Button("START") {
                        gameVar.buttonStart = true
                        serverGameHandling.startGame()
                    }
                    .padding(.trailing, 30.0)
                    .disabled(gameVar.buttonStart)
                    .alert("Invalid Player in Game", isPresented: $gameVar.invalidPlayerAlert) {
                        
                    } message: {
                        Text("Please remove players without any chip or have them buy in to start game.")
                    }

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
                        serverGameHandling.serverHandleSelf(action: ClientAction(betSize: Decimal(clientRaising), clientAction: .raise))
                        
                    } else {
                        client?.returnAction(clientAction: ClientAction(betSize: Decimal(clientRaising), clientAction: .raise))
                    }
                }) {
                    Spacer()
                    Slider(value: $clientRaising, in: 1...Double(truncating: gameVar.chipCount as NSNumber), step: Double(truncating: gameVar.bigBlind as NSNumber))
                    Text(" \(clientRaising, specifier: "%.2f")")
                    Spacer()
                    Button("Done") {
                        raiseAlert = false
                    }
                }
                Spacer()
            }
        }
        .alert("Duplicate Name", isPresented: $gameVar.invalidPlayerNameClientAlert, actions: {
            Button("OK", role: .cancel) {
                gameVar.fullScreen = false
            }
        }) {
            Text("Please change to another name")
        }
    }
}

extension View {
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        condition ? AnyView(transform(self)) : AnyView(self)
    }
}

#Preview {
    Gameview(gameVar: GameVariables(name: "HIHI", chipCount: 100, devices: [String](), isServer: false), serverGameHandling: ServerGameHandling(server: PeerListener(), gameVar: GameVariables(name: "HI", chipCount: 0, devices: [String](), isServer: false)))
}
