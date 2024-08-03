import Foundation
import Network

class PeerBrowser: ObservableObject {
    var browser: NWBrowser?
    var connection: NWConnection?
    @Published var messages: [String] = []
    var gameVar: GameVariables?
    @Published var results: [NWBrowser.Result] = [NWBrowser.Result]()
    var playerRecord: PlayerRecord?
    
    
    func setVar(gameVar: GameVariables) {
        self.gameVar = gameVar
    }
    
    func startBrowsing() {
        let parameters = NWParameters()
        let browser = NWBrowser(for: .bonjour(type: "_pokerchip._tcp", domain: nil), using: parameters)
        
        browser.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                DispatchQueue.main.async {
                    self.messages.append("Browser is ready")
                }
            case .failed(let error):
                DispatchQueue.main.async {
                    self.messages.append("Browser failed with error: \(error)")
                }
            default:
                break
            }
        }
        
        browser.browseResultsChangedHandler = { results, changes in
            self.handleResults(results: results)
            /*self.gameVar?.devices.removeAll()
            for result in results {
                switch result.endpoint {
                case .service(let name, let type, let domain, let interface):
                    DispatchQueue.main.async {
                        if name != self.gameVar?.name && !self.gameVar!.devices.contains(name) {
                            self.gameVar?.devices.append(name)
                        }
                    }
                    //self.connect(to: result.endpoint)
                default:
                    break
                }
            }*/
        }
        
        browser.start(queue: .main)
        self.browser = browser
    }
    
    func handleResults(results: Set<NWBrowser.Result>) {
        self.results = [NWBrowser.Result]()
        for result in results {
            if case let NWEndpoint.service(name: name, type: _, domain: _, interface: _) = result.endpoint {
                if name != self.gameVar?.name {
                    self.results.append(result)
                }
            }
        }
    }
    
    func connect(to endpoint: NWEndpoint) {
        let connection = NWConnection(to: endpoint, using: NWParameters())
        self.connection = connection
        
        self.connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                DispatchQueue.main.async {
                    self.messages.append("Client connected to service")
                }
                self.sendStartGame()
                self.receive()
            case .failed(let error):
                self.gameVar?.fullScreen = false
                DispatchQueue.main.async {
                    self.messages.append("Client failed with error: \(error)")
                }
            case .cancelled:
                self.gameVar?.forceCashOutAlert = true
            default:
                break
            }
        }
        connection.start(queue: .main)
        browser?.cancel()
    }
    
    private func receive() {
        connection?.receiveMessage { (content, context, isComplete, error) in
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
                    let decoder = JSONDecoder()
                    do {
                        let playerList = try decoder.decode(PlayerList.self, from: content!)
                        self.gameVar?.playerList = playerList
                        self.gameVar?.bigBlind = playerList.blinds.last ?? 0
                        for i in 0...(self.gameVar?.playerList.playerList.count)!-1 {
                            if self.gameVar!.playerList.playerList[i].name == self.gameVar?.name {
                                self.gameVar?.chipCount = playerList.playerList[i].chip + playerList.playerList[i].raiseSize
                                self.playerRecord?.update(to: playerList.playerList[i].playerRecord!)
                                break
                            }
                        }
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                case .startGame:
                    self.messages.append("received start game at client")
                case .action:
                    let decoder = JSONDecoder()
                    do {
                        let action = try decoder.decode(Action.self, from: content!)
                        self.handleAction(action: action)
                    } catch {
                        print(error.localizedDescription)
                    }
                case .clientAction:
                    print("Client received client action error")
                case .buyIn:
                    // TODO: Implement buyin limit from server
                    break
                case .leave:
                    let decoder = JSONDecoder()
                    do {
                        let leftPlayers = try decoder.decode(PlayerList.self, from: content!)
                        self.gameVar?.leftPlayers = leftPlayers
                        self.connection?.cancel()
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            if error == nil {
                // Continue to receive more messages until you receive an error.
                self.receive()
            }
        }
    }
    
    func sendReBuyIn(rebuy: Double) {
        // Create a message object to hold the command type.
        let message1 = NWProtocolFramer.Message(gameMessageType: .buyIn)
        let context = NWConnection.ContentContext(identifier: "BuyIn",
                                                  metadata: [message1])
        // Send the app content along with the message.
        
        let content = BuyIn(playerName: gameVar?.name ?? "", buyIn: rebuy)
        let encoder = JSONEncoder()
        // Send the app content along with the message.let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(content)
            self.connection?.send(content: data, contentContext: context, isComplete: true, completion: .idempotent)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func sendStartGame() {
        // Create a message object to hold the command type.
        let message1 = NWProtocolFramer.Message(gameMessageType: .startGame)
        let context = NWConnection.ContentContext(identifier: "StartGame",
                                                  metadata: [message1])
        // Send the app content along with the message.
        
        let content = Player(name: gameVar!.name, chip: gameVar!.buyIn, playerRecord: playerRecord ?? PlayerRecord(playerName: "Unavailable"), buyIn: gameVar!.buyIn)
        let encoder = JSONEncoder()
        // Send the app content along with the message.let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(content)
            self.connection?.send(content: data, contentContext: context, isComplete: true, completion: .idempotent)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    private func send(message: String) {
        // Create a message object to hold the command type.
        let message1 = NWProtocolFramer.Message(gameMessageType: .selectedCharacter)
        let context = NWConnection.ContentContext(identifier: "SelectCharacter",
                                                  metadata: [message1])
        // Send the app content along with the message.
        connection?.send(content: message.data(using: .utf8), contentContext: context, isComplete: true, completion: .idempotent)
    }
    
    func sendLeaveGame(playerName: String) {
        // Create a message object to hold the command type.
        let message1 = NWProtocolFramer.Message(gameMessageType: .leave)
        let context = NWConnection.ContentContext(identifier: "Leave",
                                                  metadata: [message1])
        // Send the app content along with the message.
        connection?.send(content: playerName.data(using: .utf8), contentContext: context, isComplete: true, completion: .idempotent)
    }
    
    func handleAction(action: Action) {
        gameVar?.playerList = action.playerList
        gameVar?.buttonCall = action.optionCall
        gameVar?.buttonRaise = action.optionRaise
        gameVar?.buttonCheck = action.optionCheck
        gameVar?.buttonFold = action.optionFold
        gameVar?.curAction = action
    }
    
    func returnAction(clientAction: ClientAction) {
        // Create a message object to hold the command type.
        let message1 = NWProtocolFramer.Message(gameMessageType: .clientAction)
        let context = NWConnection.ContentContext(identifier: "ClientAction",
                                                  metadata: [message1])
        // Send the app content along with the message.
        
        let content = clientAction
        let encoder = JSONEncoder()
        // Send the app content along with the message.let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(content)
            self.connection?.send(content: data, contentContext: context, isComplete: true, completion: .idempotent)
        } catch {
            print(error.localizedDescription)
        }
    }
}
