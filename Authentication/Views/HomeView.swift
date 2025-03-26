import SwiftUI

struct HomeView: View {
    @Binding var isAuthenticated: Bool
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject var loginViewModel: LoginViewModel
    @StateObject private var notificationService = NotificationSimulatorService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("CompanyLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
                    .padding(.top, 40)
                
                Text("Welcome, \(loginViewModel.loggedInUsername)")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.logout()
                        loginViewModel.clearCredentials()
                        isAuthenticated = false
                    }
                }) {
                    Text("Logout")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitle("Home", displayMode: .inline)
            .onAppear {
                // Reset badge count when app is opened
                notificationService.resetBadgeCount()
                
                // Request notification permission when home view appears
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        print("Notification permission granted")
                    } else if let error = error {
                        print("Error requesting notification permission: \(error)")
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView(isAuthenticated: .constant(true), loginViewModel: LoginViewModel())
} 
