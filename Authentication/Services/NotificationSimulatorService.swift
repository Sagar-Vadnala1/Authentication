import Foundation
import SwiftUI
import UserNotifications

class NotificationSimulatorService: ObservableObject {
    private var timer: Timer?
    @Published var isSimulatorRunning = false
    private var notificationCount = 0
    
    init() {
        startSendingNotifications()
    }
    
    private func startSendingNotifications() {
        isSimulatorRunning = true
        // Send first notification immediately
        sendNotification()
        
        // Then start the timer for subsequent notifications
        timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
            self?.sendNotification()
        }
    }
    
    private func sendNotification() {
        notificationCount += 1
        let content = UNMutableNotificationContent()
        content.title = "New Update"
        content.body = "This is a test notification sent at \(Date().formatted())"
        content.sound = .default
        content.badge = (notificationCount) as NSNumber
        
        // Add a trigger to show the notification immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            } else {
                print("Notification sent successfully with badge count: \(self.notificationCount)")
            }
        }
    }
    
    func resetBadgeCount() {
        notificationCount = 0
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    deinit {
        timer?.invalidate()
    }
} 
