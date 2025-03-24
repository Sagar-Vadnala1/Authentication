import SwiftUI

struct HomeView: View {
    @Binding var isAuthenticated: Bool
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject var loginViewModel: LoginViewModel
    
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
        }
    }
}

#Preview {
    HomeView(isAuthenticated: .constant(true), loginViewModel: LoginViewModel())
} 
