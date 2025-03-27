import Foundation
import Network

class WebSocketService: NSObject, ObservableObject {
    private var webSocket: URLSessionWebSocketTask?
    private let serverURL = URL(string: "ws://192.168.0.100:8080")!
    @Published var isConnected = false
    
    override init() {
        super.init()
        connect()
    }
    
    func connect() {
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: serverURL)
        webSocket?.resume()
        
        receiveMessage()
    }
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self?.handleMessage(text)
                    }
                @unknown default:
                    break
                }
                // Continue receiving messages
                self?.receiveMessage()
                
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                self?.isConnected = false
                // Attempt to reconnect after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self?.connect()
                }
            }
        }
    }
    
    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let notification = try? JSONDecoder().decode(ServerNotification.self, from: data) else {
            return
        }
        
        // Post notification to be handled by the app
        NotificationCenter.default.post(
            name: .newServerNotification,
            object: nil,
            userInfo: ["notification": notification]
        )
    }
    
    func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        isConnected = false
    }
    
    deinit {
        disconnect()
    }
}

// MARK: - Models
struct ServerNotification: Codable {
    let id: Int
    let type: String
    let timestamp: String
    let title: String
    let body: String
    let priority: String
}

// MARK: - Notification Names
extension Notification.Name {
    static let newServerNotification = Notification.Name("newServerNotification")
} 
