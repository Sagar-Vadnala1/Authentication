import Foundation

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let access_token: String
    let expires_in: Int
    let refresh_expires_in: Int
    let refresh_token: String
    let token_type: String
    let session_state: String
    let scope: String
    let error: String?
    let error_description: String?
    let error_uri: String?
    let preferred_username: String?
    
    var token: String? {
        return access_token
    }
    
    var success: Bool {
        return error == nil && !access_token.isEmpty
    }
    
    var message: String {
        return error_description ?? error ?? "Login successful"
    }
} 