import Foundation
import Network

class ChatBotWebSocketService: NSObject, ObservableObject {
    private var webSocket: URLSessionWebSocketTask?
    private let serverURL = URL(string: "ws://localhost:8090")!
    @Published var isConnected = false
    @Published var messages: [ChatMessage] = []
    
    var onStartTyping: (() -> Void)?
    var onEndTyping: (() -> Void)?
    
    override init() {
        super.init()
        connect()
    }
    
    func connect() {
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: serverURL)
        webSocket?.resume()
        isConnected = true
        receiveMessage()
    }
    
    func sendMessage(_ text: String) {
        let userMessage = ChatMessage(text: text, isUser: true, timestamp: Date())
        DispatchQueue.main.async {
            self.messages.append(userMessage)
        }
        
        // Format message as expected by server
        let messageDict: [String: Any] = [
            "type": "user_message",
            "message": text
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: messageDict),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Error encoding message")
            return
        }
        
        // Show typing indicator before sending
        DispatchQueue.main.async {
            self.onStartTyping?()
        }
        
        webSocket?.send(.string(jsonString)) { [weak self] error in
            if let error = error {
                print("Error sending message: \(error)")
                self?.isConnected = false
                DispatchQueue.main.async {
                    self?.onEndTyping?()
                }
                // Try to reconnect
                self?.connect()
            }
        }
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
                DispatchQueue.main.async {
                    self?.onEndTyping?()
                }
                // Attempt to reconnect after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self?.connect()
                }
            }
        }
    }
    
    private func handleMessage(_ text: String) {
        print("Received message: \(text)") // Debug print
        
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("Error parsing message")
            DispatchQueue.main.async {
                self.onEndTyping?()
            }
            return
        }
        
        // Simulate typing delay based on message length
        DispatchQueue.main.asyncAfter(deadline: .now() + calculateTypingDelay(for: text)) { [weak self] in
            var messageText = ""
            
            if let type = json["type"] as? String {
                switch type {
                case "diagnostic_suggestion":
                    // Build a formatted message with all diagnostic information
                    if let baseMessage = json["message"] as? String {
                        messageText = baseMessage
                        
                        if let conditions = json["conditions"] as? [[String: Any]] {
                            for (index, condition) in conditions.enumerated() {
                                if let name = condition["name"] as? String,
                                   let details = condition["details"] as? [String: Any],
                                   let treatment = details["treatment"] as? String,
                                   let urgency = details["urgency"] as? String,
                                   let followUp = details["followUp"] as? String {
                                    
                                    messageText += "\n\n\(index + 1). \(name.capitalized)"
                                    messageText += "\nUrgency: \(urgency.capitalized)"
                                    messageText += "\nTreatment: \(treatment)"
                                    messageText += "\nFollow-up: \(followUp)"
                                }
                            }
                        }
                        
                        if let questions = json["additionalQuestions"] as? [String], !questions.isEmpty {
                            messageText += "\n\nAdditional Questions:"
                            for question in questions {
                                messageText += "\n• \(question)"
                            }
                        }
                        
                        if let disclaimer = json["disclaimer"] as? String {
                            messageText += "\n\n\(disclaimer)"
                        }
                    }
                    
                case "connection_established", "bot_response":
                    messageText = json["message"] as? String ?? "No message content"
                    
                case "error":
                    messageText = json["message"] as? String ?? "An unknown error occurred"
                    
                default:
                    messageText = json["message"] as? String ?? "Unexpected response"
                }
            } else {
                messageText = json["message"] as? String ?? "Unexpected response format"
            }
            
            let botMessage = ChatMessage(text: messageText, isUser: false, timestamp: Date())
            self?.messages.append(botMessage)
            self?.onEndTyping?()
        }
    }
    
    private func calculateTypingDelay(for text: String) -> TimeInterval {
        // Calculate a natural-feeling delay based on message length
        let baseDelay = 1.0 // Minimum delay
        let wordsCount = text.split(separator: " ").count
        let characterCount = text.count
        
        // Approximately 200 words per minute reading speed
        let readingDelay = Double(wordsCount) * 0.3
        // Add some time for each character to simulate typing
        let typingDelay = Double(characterCount) * 0.01
        
        return min(baseDelay + readingDelay + typingDelay, 4.0) // Cap at 4 seconds
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
struct ChatMessage: Codable, Identifiable, Equatable {
    var id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
    
    init(text: String, isUser: Bool, timestamp: Date) {
        self.id = UUID()
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.text == rhs.text &&
        lhs.isUser == rhs.isUser &&
        lhs.timestamp == rhs.timestamp
    }
}

struct ChatBotResponse: Codable {
    let type: String
    let message: String
    let timestamp: String
    let conditions: [DiagnosisCondition]?
    let additionalQuestions: [String]?
    let disclaimer: String?
}

struct DiagnosisCondition: Codable {
    let name: String
    let details: DiagnosisDetails
    let matchedSymptoms: [String]
    let additionalSymptoms: [String]
}

struct DiagnosisDetails: Codable {
    let symptoms: [String]
    let treatment: String
    let urgency: String
    let followUp: String
} 
