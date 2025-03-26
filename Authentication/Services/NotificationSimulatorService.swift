import Foundation
import SwiftUI
import UserNotifications

class NotificationSimulatorService: NSObject, ObservableObject {
    private var timer: Timer?
    @Published var isSimulatorRunning = false
    private var notificationCount = 0
    
    override init() {
        super.init()
        startSendingNotifications()
        setupNotificationCenterDelegate()
    }
    
    private func setupNotificationCenterDelegate() {
        UNUserNotificationCenter.current().delegate = self
    }
    
    private func startSendingNotifications() {
//        isSimulatorRunning = true
//        // Send first notification immediately
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
        content.badge = NSNumber(value: notificationCount)
        
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

// MARK: - UNUserNotificationCenterDelegate
extension NotificationSimulatorService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        // When user taps on notification
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // When app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              openSettingsFor notification: UNNotification?) {
        // When user opens notification settings
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didRemoveAllPendingNotificationRequests: Bool) {
        // When all pending notifications are removed
        resetBadgeCount()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didRemovePendingNotificationRequestsWithIdentifiers identifiers: [String]) {
        // When specific notifications are removed
        // Check if all notifications are removed
        center.getPendingNotificationRequests { requests in
            if requests.isEmpty {
                DispatchQueue.main.async {
                    self.resetBadgeCount()
                }
            }
        }
    }
} 
