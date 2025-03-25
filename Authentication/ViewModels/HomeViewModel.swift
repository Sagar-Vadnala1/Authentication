import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    func logout() async {
        do {
            try await NetworkService.shared.logout()
        } catch {
            print("Logout error: \(error)")
        }
    }
} 