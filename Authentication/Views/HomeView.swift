import SwiftUI

struct HomeView: View {
    @Binding var isAuthenticated: Bool
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject var loginViewModel: LoginViewModel
    @StateObject private var notificationService = NotificationSimulatorService()
    @EnvironmentObject private var inAppNotificationService: InAppNotificationService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(.companyLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
                    .padding(.top, 40)
                
                Text("Welcome, \(loginViewModel.loggedInUsername)")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                // Test different types of in-app notifications
                VStack(spacing: 12) {
                    Button(action: {
                        inAppNotificationService.show(
                            title: "Success",
                            message: "Operation completed successfully!",
                            backgroundColor: .green,
                            textColor: .white
                        )
                    }) {
                        Text("Show Success Notification")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        inAppNotificationService.show(
                            title: "Warning",
                            message: "Please review your input",
                            backgroundColor: .orange,
                            textColor: .white
                        )
                    }) {
                        Text("Show Warning Notification")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        inAppNotificationService.show(
                            title: "Error",
                            message: "Something went wrong",
                            backgroundColor: .red,
                            textColor: .white
                        )
                    }) {
                        Text("Show Error Notification")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                
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
                notificationService.resetBadgeCount()
            }
        }
    }
}

#Preview {
    HomeView(isAuthenticated: .constant(true), loginViewModel: LoginViewModel())
        .environmentObject(InAppNotificationService())
} 
