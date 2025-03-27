import Foundation
import SwiftUI
import UserNotifications

class NotificationSimulatorService: NSObject, ObservableObject {
    @Published var notificationCount = 0
    
    override init() {
        super.init()
        setupNotificationCategories()
    }
    
    private func setupNotificationCategories() {
        // Define notification categories and actions
        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "View",
            options: .foreground
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: .destructive
        )
        
        let category = UNNotificationCategory(
            identifier: "GENERAL",
            actions: [viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func sendNotification(title: String = "New Update", body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = NSNumber(value: notificationCount + 1)
        content.categoryIdentifier = "GENERAL"
        
        // Add user info for handling notification tap
        content.userInfo = ["timestamp": Date().timeIntervalSince1970]
        
        // Create trigger for immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                print("Error sending notification: \(error)")
            } else {
                DispatchQueue.main.async {
                    self?.notificationCount += 1
                }
            }
        }
    }
    
    func resetBadgeCount() {
        notificationCount = 0
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationSimulatorService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification actions
        switch response.actionIdentifier {
        case "VIEW_ACTION":
            // Handle view action
            print("View action tapped")
        case "DISMISS_ACTION":
            // Handle dismiss action
            print("Dismiss action tapped")
        default:
            // Handle default tap
            print("Notification tapped")
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
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
