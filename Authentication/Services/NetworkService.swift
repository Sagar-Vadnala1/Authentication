import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(String)
    case invalidResponse(Int, Data?)
}

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "https://bdev.hikigaidemo.com"
    private var authToken: String?
    private var refreshToken: String?
    
    private init() {}
    
    func login(username: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw NetworkError.invalidURL
        }
        
        let loginRequest = LoginRequest(username: username, password: password)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(loginRequest)
        
        print("Sending request to: \(url.absoluteString)")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response type")
        }
        
        print("Received status code: \(httpResponse.statusCode)")
        
        // Print response data for debugging
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response data: \(responseString)")
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                self.authToken = loginResponse.access_token
                self.refreshToken = loginResponse.refresh_token
                return loginResponse
            } catch {
                print("Decoding error: \(error)")
                throw NetworkError.decodingError(error)
            }
        case 401:
            if let errorResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.error_description ?? "Authentication failed")
            }
            throw NetworkError.invalidResponse(401, data)
        default:
            throw NetworkError.invalidResponse(httpResponse.statusCode, data)
        }
    }
    
    func logout() async throws {
        guard let url = URL(string: "\(baseURL)/logoutUser") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        }
        
        // Clear the stored tokens
        self.authToken = nil
        self.refreshToken = nil
    }
} 
