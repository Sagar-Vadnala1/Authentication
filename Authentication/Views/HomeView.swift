import SwiftUI

struct HomeView: View {
    @Binding var isAuthenticated: Bool
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = loginViewModel.currentUser {
                    Text("Welcome, \(user.name)")
                        .font(.largeTitle)
                        .padding()
                    
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("Welcome")
                        .font(.largeTitle)
                        .padding()
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
            .navigationBarTitle("Home", displayMode: .large)
        }
    }
}

#Preview {
    HomeView(isAuthenticated: .constant(true), loginViewModel: LoginViewModel())
} 