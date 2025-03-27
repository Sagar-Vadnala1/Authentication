import Foundation
import SwiftUI
import UserNotifications

class WebSocketService: ObservableObject {
    @Published var isConnected = false
    @Published var lastNotification: String?
    
    init() {
        requestNotificationPermission()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isConnected = granted
                if granted {
                    print("Notification permission granted")
                } else if let error = error {
                    print("Error requesting notification permission: \(error)")
                }
            }
        }
    }
} 
