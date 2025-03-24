import Foundation
import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var loggedInUsername: String = ""
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        // Check if user is already logged in
        if let savedUsername = userDefaults.string(forKey: "loggedInUsername"),
           let _ = userDefaults.string(forKey: "authToken") {
            self.loggedInUsername = savedUsername
            self.isAuthenticated = true
        }
    }
    
    func login() async {
        guard !username.isEmpty && !password.isEmpty else {
            errorMessage = "Please enter both username and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await NetworkService.shared.login(username: username, password: password)
            if response.success {
                loggedInUsername = response.preferred_username ?? username
                isAuthenticated = true
                
                // Save authentication state
                userDefaults.setValue(loggedInUsername, forKey: "loggedInUsername")
                userDefaults.setValue(response.access_token, forKey: "authToken")
                userDefaults.setValue(response.refresh_token, forKey: "refreshToken")
            } else {
                errorMessage = response.message
            }
        } catch NetworkError.invalidResponse(let statusCode, let data) {
            if statusCode == 401 {
                errorMessage = "Invalid username or password"
            } else {
                if let data = data, let errorResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                    errorMessage = errorResponse.message
                } else {
                    errorMessage = "Server error: Status code \(statusCode)"
                }
            }
        } catch NetworkError.decodingError(let error) {
            errorMessage = "Failed to process server response: \(error.localizedDescription)"
        } catch NetworkError.serverError(let message) {
            errorMessage = message
        } catch {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func clearCredentials() {
        username = ""
        password = ""
        errorMessage = nil
        isAuthenticated = false
        loggedInUsername = ""
        
        // Clear saved authentication state
        userDefaults.removeObject(forKey: "loggedInUsername")
        userDefaults.removeObject(forKey: "authToken")
        userDefaults.removeObject(forKey: "refreshToken")
    }
} 