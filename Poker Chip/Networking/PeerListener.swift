import Foundation
import Network

class PeerListener: ObservableObject {
    var listener: NWListener?
    var connections: [NWConnection] = [NWConnection]()
    @Published var messages: [String] = []
    var gameVar: GameVariables?
    var serverGameHandling: ServerGameHandling?
    
    func setVar(gameVar: GameVariables) {
        self.gameVar = gameVar
    }
    
    func stopListening() {
        if let listener = listener {
            listener.cancel()
            connections.removeAll()
        }
    }
    func startListening() {
        do {
            connections = [NWConnection]()
            
            listener = try NWListener(using: NWParameters())
            
            listener?.service = NWListener.Service(name: gameVar?.name, type: "_pokerchip._tcp")
            
            listener?.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    DispatchQueue.main.async {
                        self.messages.append("Server is ready and advertising via Bonjour")
                    }
                case .failed(let error):
                    DispatchQueue.main.async {
                        self.messages.append("Server failed with error: \(error)")
                    }
                case .cancelled:
                    DispatchQueue.main.async {
                        self.messages.append("Server stopped")
                    }
                default:
                    break
                }
            }
            
            listener?.newConnectionHandler = { [weak self] connection in
                DispatchQueue.main.async {
                    self?.messages.append("New connection received")
                }
                self?.handleNewConnection(connection)
            }
            
            listener?.start(queue: .main)
        } catch {
            DispatchQueue.main.async {
                self.messages.append("Failed to create listener: \(error)")
            }
        }
    }
    
    private func handleNewConnection(_ connection: NWConnection) {
        connection.start(queue: .main)
        DispatchQueue.global().async {
            self.receive(on: connection)
        }
        self.connections.append(connection)
    }
    
    private func receive(on connection: NWConnection) {
        connection.receiveMessage { content, context, isComplete, error in
            // Extract your message type from the received context.
            if let gameMessage = context?.protocolMetadata(definition: GameProtocol.definition) as? NWProtocolFramer.Message {
                switch gameMessage.gameMessageType {
                case .invalid:
                    print("Received invalid message")
                case .selectedCharacter:
                    self.messages.append("SELECTED CHARACTER")
                case .move:
                    self.messages.append("HANDLE MOVE")
                case .playerList:
                    print("HI")
                case .startGame:
                    let decoder = JSONDecoder()
                    do {
                        var player = try decoder.decode(Player.self, from: content!)
                        player.chip = player.chip * (self.gameVar?.bigBlind ?? 0)
                        self.gameVar?.playerList.playerList.append(player)
                        self.sendPlayerList()
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                case .action:
                    print("Server side received action request")
                case .clientAction:
                    let decoder = JSONDecoder()
                    do {
                        let clientAction = try decoder.decode(ClientAction.self, from: content!)
                        // TODO: add handle client action
                        let framerMessage = NWProtocolFramer.Message(gameMessageType: .action)
                        let context = NWConnection.ContentContext(identifier: "Action",
                                                                  metadata: [framerMessage])
                        let encoder = JSONEncoder()
                        // lock all buttons after successfully receiving action
                        do {
                            let data = try encoder.encode(Action(playerList: self.gameVar!.playerList, betSize: self.serverGameHandling!.bettingSize, optionCall: true, optionRaise: true, optionCheck: true, optionFold: true))
                            connection.send(content: data, contentContext: context, isComplete: true, completion: .idempotent)
                        } catch {
                            print(error.localizedDescription)
                        }
                        self.serverGameHandling?.serverHandleClient(action: clientAction)
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                case .buyIn:
                    let decoder = JSONDecoder()
                    do {
                        let clientBuyIn = try decoder.decode(BuyIn.self, from: content!)
                        // TODO: add handle client action
                        self.serverGameHandling?.handleClientRebuy(rebuy: clientBuyIn)
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                case .leave:
                    let leaveName = String(decoding: content!, as: UTF8.self)
                    self.serverGameHandling?.handleClientLeave(name: leaveName)
                    
                }
            }
            if error == nil {
                // Continue to receive more messages until you receive an error.
                self.receive(on: connection)
            }
        }
    }
    
    func requestAction(idx: Int, action: Action) {
        let connection = self.connections[idx]
        let framerMessage = NWProtocolFramer.Message(gameMessageType: .action)
        let context = NWConnection.ContentContext(identifier: "Action",
                                                  metadata: [framerMessage])
        let encoder = JSONEncoder()
        // Send the app content along with the message.let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(action)
            connection.send(content: data, contentContext: context, isComplete: true, completion: .idempotent)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func sendPlayerList() {
        for connection in self.connections {
            // Create a message object to hold the command type.
            let framerMessage = NWProtocolFramer.Message(gameMessageType: .playerList)
            let context = NWConnection.ContentContext(identifier: "PlayerList",
                                                      metadata: [framerMessage])
            let encoder = JSONEncoder()
            // Send the app content along with the message.let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(self.gameVar?.playerList ?? PlayerList())
                connection.send(content: data, contentContext: context, isComplete: true, completion: .idempotent)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func sendLeaveGame(idx: Int, removeFromConnections: Bool) {
        let framerMessage = NWProtocolFramer.Message(gameMessageType: .leave)
        let context = NWConnection.ContentContext(identifier: "Leave",
                                                  metadata: [framerMessage])
        let encoder = JSONEncoder()
        // Send the app content along with the message.let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self.gameVar?.leftPlayers ?? PlayerList())
            connections[idx].send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed({ error in
                if error != nil {
                    print("Send failed with error: \(String(describing: error))")
                } else {
                    self.connections[idx].cancel()
                    if removeFromConnections {
                        self.connections.remove(at: idx)
                    }
                }
            }))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func send(message: String) {
        for connection in self.connections {
            // Create a message object to hold the command type.
            let message1 = NWProtocolFramer.Message(gameMessageType: .selectedCharacter)
            let context = NWConnection.ContentContext(identifier: "SelectCharacter",
                                                      metadata: [message1])
            // Send the app content along with the message.
            connection.send(content: message.data(using: .utf8), contentContext: context, isComplete: true, completion: .idempotent)
        }
    }
}
