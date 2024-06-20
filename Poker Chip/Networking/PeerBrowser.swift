import Foundation
import Network

class PeerBrowser: ObservableObject {
    var browser: NWBrowser?
    var connection: NWConnection?
    @Published var messages: [String] = []
    var gameVar: GameVariables?
    var results: [NWBrowser.Result] = [NWBrowser.Result]()
    
    
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
        let connection = NWConnection(to: endpoint, using: .tcp)
        self.connection = connection
        
        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                DispatchQueue.main.async {
                    self.messages.append("Client connected to service")
                }
                self.send(message: "Hello from Client!")
                self.receive()
            case .failed(let error):
                DispatchQueue.main.async {
                    self.messages.append("Client failed with error: \(error)")
                }
            default:
                break
            }
        }
        
        connection.start(queue: .main)
    }
    
    private func receive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                let message = String(decoding: data, as: UTF8.self)
                DispatchQueue.main.async {
                    self.messages.append("Received message: \(message)")
                }
            }
            
            if isComplete {
                self.connection?.cancel()
            } else if let error = error {
                DispatchQueue.main.async {
                    self.messages.append("Receive error: \(error)")
                }
                self.connection?.cancel()
            } else {
                self.receive()
            }
        }
    }
    
    private func send(message: String) {
        let data = message.data(using: .utf8)
        connection?.send(content: data, completion: .contentProcessed({ sendError in
            if let sendError = sendError {
                DispatchQueue.main.async {
                    self.messages.append("Send error: \(sendError)")
                }
            }
        }))
    }
}
