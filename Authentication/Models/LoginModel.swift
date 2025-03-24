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
    
    // User information from JWT token
    let name: String?
    let email: String?
    let given_name: String?
    let family_name: String?
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
    
    var user: User? {
        guard let name = name,
              let email = email,
              let givenName = given_name,
              let familyName = family_name,
              let preferredUsername = preferred_username else {
            return nil
        }
        
        return User(name: name,
                   email: email,
                   givenName: givenName,
                   familyName: familyName,
                   preferredUsername: preferredUsername)
    }
} 