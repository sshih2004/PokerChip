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
            let params = NWParameters.tcp
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
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                let message = String(decoding: data, as: UTF8.self)
                DispatchQueue.main.async {
                    self.messages.append("Received message: \(message)")
                }
                self.send(on: connection, message: "Echo: \(message)")
            }
            
            if isComplete {
                connection.cancel()
            } else if let error = error {
                DispatchQueue.main.async {
                    self.messages.append("Receive error: \(error)")
                }
                connection.cancel()
            } else {
                self.receive(on: connection)
            }
        }
    }
    
    private func send(on connection: NWConnection, message: String) {
        let data = message.data(using: .utf8)
        connection.send(content: data, completion: .contentProcessed({ sendError in
            if let sendError = sendError {
                DispatchQueue.main.async {
                    self.messages.append("Send error: \(sendError)")
                }
            }
        }))
    }
}
