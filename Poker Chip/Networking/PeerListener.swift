import Foundation
import Network

class PeerListener: ObservableObject {
    var listener: NWListener?
    @Published var messages: [String] = []
    var gameVar: GameVariables?
    
    func setVar(gameVar: GameVariables) {
        self.gameVar = gameVar
    }
    
    func stopListening() {
        if let listener = listener {
            listener.cancel()
        }
    }
    func startListening() {
        do {
            let params = NWParameters.applicationService
            
            
            listener = try NWListener(using: params)
            
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
        receive(on: connection)
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
                }
            }
            if error == nil {
                // Continue to receive more messages until you receive an error.
                self.receive(on: connection)
            }
        }
    }
    
    private func send(on connection: NWConnection, message: String) {
        // Create a message object to hold the command type.
        let message1 = NWProtocolFramer.Message(gameMessageType: .selectedCharacter)
        let context = NWConnection.ContentContext(identifier: "SelectCharacter",
                                                  metadata: [message1])
        // Send the app content along with the message.
        connection.send(content: message.data(using: .utf8), contentContext: context, isComplete: true, completion: .idempotent)
    }
}
