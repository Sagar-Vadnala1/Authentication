import SwiftUI

struct Drawer: View {
    @Binding var isAuthenticated: Bool
    @ObservedObject var loginViewModel: LoginViewModel
    @Binding var isOpen: Bool
    @Binding var selectedTab: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dimmed background
                if isOpen {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isOpen = false
                            }
                        }
                }
                
                // Drawer content
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        // Profile Header
                        VStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("Dr. \(loginViewModel.loggedInUsername)")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Medical Professional")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                        .background(Color(.systemGray6))
                        
                        // Menu Items
                        VStack(spacing: 0) {
                            DrawerMenuItem(
                                icon: "house.fill",
                                title: "Home",
                                isSelected: selectedTab == 0
                            ) {
                                selectedTab = 0
                                withAnimation(.spring()) {
                                    isOpen = false
                                }
                            }
                            
                            DrawerMenuItem(
                                icon: "person.fill",
                                title: "Profile",
                                isSelected: selectedTab == 1
                            ) {
                                selectedTab = 1
                                withAnimation(.spring()) {
                                    isOpen = false
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        
                        Spacer()
                        
                        // Logout Button
                        Button(action: {
                            Task {
                                await logout()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 20))
                                Text("Logout")
                                    .font(.body)
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                        }
                    }
                    .frame(width: min(geometry.size.width * 0.8, 300))
                    .background(Color(.systemBackground))
                    .offset(x: isOpen ? 0 : -min(geometry.size.width * 0.8, 300))
                    
                    Spacer()
                }
            }
        }
        .animation(.spring(), value: isOpen)
    }
    
    private func logout() async {
        loginViewModel.clearCredentials()
        isAuthenticated = false
    }
}

struct DrawerMenuItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.body)
                Spacer()
            }
            .foregroundColor(isSelected ? .blue : .primary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        }
    }
} 