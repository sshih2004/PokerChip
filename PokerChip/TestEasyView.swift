import SwiftUI

struct TestEasyView: View {
    @ObservedObject var server = PeerListener()
    @ObservedObject var client = PeerBrowser()
    
    var body: some View {
        VStack {
            Button(action: {
                server.startListening()
            }) {
                Text("Start Server")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Button(action: {
                client.startBrowsing()
            }) {
                Text("Start Client")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            List {
                Section(header: Text("Server Messages")) {
                    ForEach(server.messages, id: \.self) { message in
                        Text(message)
                    }
                }
                
                Section(header: Text("Client Messages")) {
                    ForEach(client.messages, id: \.self) { message in
                        Text(message)
                    }
                }
            }
        }
        .navigationBarTitle("P2P Chat", displayMode: .inline)
    }
}

