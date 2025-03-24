import Foundation

struct User: Codable {
    let name: String
    let email: String
    let givenName: String
    let familyName: String
    let preferredUsername: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
        case givenName = "given_name"
        case familyName = "family_name"
        case preferredUsername = "preferred_username"
    }
} 