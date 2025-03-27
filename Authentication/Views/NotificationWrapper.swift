import SwiftUI

struct NotificationWrapper<Content: View>: View {
    let content: Content
    @StateObject private var notificationService = InAppNotificationService()
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
                .environmentObject(notificationService)
            
            if notificationService.isShowing, let notification = notificationService.currentNotification {
                VStack {
                    InAppNotificationView(notification: notification)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer()
                }
                .animation(.spring(), value: notificationService.isShowing)
            }
        }
    }
} 