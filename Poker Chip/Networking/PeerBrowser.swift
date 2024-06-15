import Foundation
import Network

class PeerBrowser: ObservableObject {
    var browser: NWBrowser?
    var connection: NWConnection?
    @Published var messages: [String] = []
    
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
            for result in results {
                switch result.endpoint {
                case .service(let name, let type, let domain, let interface):
                    DispatchQueue.main.async {
                        self.messages.append("Found service: \(name) \(type) \(domain) \(interface.debugDescription)")
                    }
                    self.connect(to: result.endpoint)
                default:
                    break
                }
            }
        }
        
        browser.start(queue: .main)
        self.browser = browser
    }
    
    private func connect(to endpoint: NWEndpoint) {
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
