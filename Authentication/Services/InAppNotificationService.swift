import SwiftUI

struct InAppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let backgroundColor: Color
    let textColor: Color
    let duration: TimeInterval
}

class InAppNotificationService: ObservableObject {
    @Published var currentNotification: InAppNotification?
    @Published var isShowing = false
    
    func show(title: String, message: String, backgroundColor: Color = .blue, textColor: Color = .white, duration: TimeInterval = 3.0) {
        let notification = InAppNotification(
            title: title,
            message: message,
            backgroundColor: backgroundColor,
            textColor: textColor,
            duration: duration
        )
        
        DispatchQueue.main.async {
            self.currentNotification = notification
            self.isShowing = true
            
            // Auto-hide after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.hide()
            }
        }
    }
    
    func hide() {
        withAnimation {
            self.isShowing = false
            self.currentNotification = nil
        }
    }
}

struct InAppNotificationView: View {
    let notification: InAppNotification
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(notification.title)
                .font(.headline)
                .foregroundColor(notification.textColor)
            
            Text(notification.message)
                .font(.subheadline)
                .foregroundColor(notification.textColor)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(notification.backgroundColor)
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 8)
        .shadow(radius: 5)
    }
} 