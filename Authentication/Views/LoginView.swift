import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        Group {
            if viewModel.isAuthenticated {
                HomeView(isAuthenticated: $viewModel.isAuthenticated, loginViewModel: viewModel)
            } else {
                NavigationView {
                    ZStack {
                        Color(.systemBackground)
                            .ignoresSafeArea()
                        
                        ScrollView {
                            VStack(spacing: 20) {
                                // Company Logo
                                Image("CompanyLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .padding(.top, 60)
                                
                                // Welcome Text
                                Text("Welcome")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("Please sign in to continue")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.bottom, 30)
                                
                                // Login Form
                                VStack(spacing: 15) {
                                    // Username Field
                                    TextField("Username", text: $viewModel.username)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .textContentType(.username)
                                        .autocapitalization(.none)
                                        .padding(.horizontal)
                                    
                                    // Password Field
                                    SecureField("Password", text: $viewModel.password)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .textContentType(.password)
                                        .padding(.horizontal)
                                    
                                    // Error Message
                                    if let errorMessage = viewModel.errorMessage {
                                        Text(errorMessage)
                                            .foregroundColor(.red)
                                            .font(.caption)
                                            .padding(.horizontal)
                                    }
                                    
                                    // Login Button
                                    Button(action: {
                                        Task {
                                            await viewModel.login()
                                        }
                                    }) {
                                        if viewModel.isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        } else {
                                            Text("Sign In")
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                    .disabled(viewModel.isLoading)
                                }
                                .padding(.top, 20)
                            }
                        }
                    }
                    .navigationBarHidden(true)
                }
            }
        }
    }
}

#Preview {
    LoginView()
} 