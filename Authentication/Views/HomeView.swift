import SwiftUI

struct HomeView: View {
    @Binding var isAuthenticated: Bool
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var chatBotService = ChatBotWebSocketService()
    @ObservedObject var loginViewModel: LoginViewModel
    @EnvironmentObject private var inAppNotificationService: InAppNotificationService
    @State private var messageText = ""
    @State private var isTyping = false
    @State private var isDrawerOpen = false
    @State private var selectedTab = 0
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                TabView(selection: $selectedTab) {
                    // Chat Tab
                    chatView
                        .tabItem {
                            Image(systemName: "message.fill")
                            Text("Chat")
                        }
                        .tag(0)
                    
                    // Profile Tab
                    ProfileView(loginViewModel: loginViewModel)
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                        .tag(1)
                }
                
                // Drawer
                Drawer(isAuthenticated: $isAuthenticated,
                      loginViewModel: loginViewModel,
                      isOpen: $isDrawerOpen,
                      selectedTab: $selectedTab)
                    .zIndex(1)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("HIKIGAI")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation(.spring()) {
                            isDrawerOpen.toggle()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 22))
                    }
                }
            }
        }
    }
    
    private var chatView: some View {
        VStack(spacing: 0) {
            // Welcome Header
            HStack {
                Image(.companyLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(.leading)
                
                VStack(alignment: .leading) {
                    Text("Hello, Doctor")
                    Text("I'm Koi, your diagnostic assistant.")
                        .fontWeight(.bold)
                }
                
                Spacer()
            }
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            
            Divider()
            
            // Chat Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Welcome message that appears immediately
                        if chatBotService.messages.isEmpty {
                            HStack(alignment: .bottom, spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Welcome to the Medical Diagnostic Assistant. How can I help you today?")
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(0)
                                    
                                    Text(Date(), style: .time)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 4)
                                }
                                .frame(maxWidth: .infinity)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                        }
                        
                        ForEach(chatBotService.messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                        
                        if isTyping {
                            TypingIndicator()
                                .transition(.opacity)
                        }
                    }
                    .padding(.vertical)
                    .animation(.spring(response: 0.3), value: chatBotService.messages)
                }
                .onChange(of: chatBotService.messages) { oldValue, newValue in
                    if let lastMessage = newValue.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            
            // Input Area
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    TextField("Type your message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isFocused)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTyping)
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .shadow(radius: 1)
        }
        .onAppear {
            chatBotService.onStartTyping = {
                withAnimation {
                    isTyping = true
                }
            }
            chatBotService.onEndTyping = {
                withAnimation {
                    isTyping = false
                }
            }
        }
    }
    
    private func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        chatBotService.sendMessage(trimmedMessage)
        messageText = ""
        isFocused = false
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                if message.isUser {
                    Text(message.text)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(24)
                } else {
                    Text(message.text)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground))
                        .cornerRadius(0)
                }
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: message.isUser ? nil : .infinity)
            
            if !message.isUser {
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

// Helper to apply different corner radii
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct TypingIndicator: View {
    @State private var phase = 0.0
    
    var body: some View {
        HStack(alignment: .bottom) {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(phase == Double(index) ? 1.5 : 1)
                        .animation(
                            .easeInOut(duration: 0.5)
                            .repeatCount(1, autoreverses: true),
                            value: phase
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(0)
            
            Spacer()
        }
        .padding(.horizontal)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                withAnimation {
                    phase = (phase + 1).truncatingRemainder(dividingBy: 3)
                }
            }
        }
    }
}

#Preview {
    HomeView(isAuthenticated: .constant(true), loginViewModel: LoginViewModel())
        .environmentObject(InAppNotificationService())
}


//                Text("Welcome, \(loginViewModel.loggedInUsername)")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .padding()

// Test different types of in-app notifications
//                VStack(spacing: 12) {
//                    Button(action: {
//                        inAppNotificationService.show(
//                            title: "Success",
//                            message: "Operation completed successfully!",
//                            backgroundColor: .green,
//                            textColor: .white
//                        )
//                    }) {
//                        Text("Show Success Notification")
//                            .fontWeight(.semibold)
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 50)
//                            .background(Color.green)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                            .padding(.horizontal)
//                    }
//
//                    Button(action: {
//                        inAppNotificationService.show(
//                            title: "Warning",
//                            message: "Please review your input",
//                            backgroundColor: .orange,
//                            textColor: .white
//                        )
//                    }) {
//                        Text("Show Warning Notification")
//                            .fontWeight(.semibold)
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 50)
//                            .background(Color.orange)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                            .padding(.horizontal)
//                    }
//
//                    Button(action: {
//                        inAppNotificationService.show(
//                            title: "Error",
//                            message: "Something went wrong",
//                            backgroundColor: .red,
//                            textColor: .white
//                        )
//                    }) {
//                        Text("Show Error Notification")
//                            .fontWeight(.semibold)
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 50)
//                            .background(Color.red)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                            .padding(.horizontal)
//                    }
//                }
