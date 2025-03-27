//
//  AppDelagate.swift
//  Authentication
//
//  Created by vivek vadnala on 26/03/25.
//

import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private let webSocketService = WebSocketService()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set up notification center delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions
        requestNotificationPermissions()
        
        // Only register for remote notifications if the capability is available
        if Bundle.main.object(forInfoDictionaryKey: "aps-environment") != nil {
            application.registerForRemoteNotifications()
        }
        
        // Set up server notification observer
        setupServerNotificationObserver()
        
        return true
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
    
    private func setupServerNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleServerNotification(_:)),
            name: .newServerNotification,
            object: nil
        )
    }
    
    @objc private func handleServerNotification(_ notification: Notification) {
        guard let serverNotification = notification.userInfo?["notification"] as? ServerNotification else { return }
        
        // Create local notification from server notification
        let content = UNMutableNotificationContent()
        content.title = serverNotification.title
        content.body = serverNotification.body
        content.sound = .default
        content.badge = 1
        
        // Add notification category based on priority
        switch serverNotification.priority {
        case "high":
            content.categoryIdentifier = "HIGH_PRIORITY"
        case "medium":
            content.categoryIdentifier = "MEDIUM_PRIORITY"
        case "low":
            content.categoryIdentifier = "LOW_PRIORITY"
        default:
            content.categoryIdentifier = "GENERAL"
        }
        
        // Add user info for handling notification tap
        content.userInfo = [
            "id": serverNotification.id,
            "type": serverNotification.type,
            "timestamp": serverNotification.timestamp
        ]
        
        // Create trigger for immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "server_notification_\(serverNotification.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // Handle foreground notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification response when app is in background or terminated
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap here
        if let userInfo = response.notification.request.content.userInfo as? [String: Any] {
            print("Notification tapped with ID: \(userInfo["id"] ?? "unknown")")
            print("Type: \(userInfo["type"] ?? "unknown")")
        }
        completionHandler()
    }
    
    // Handle remote notification registration
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
}
