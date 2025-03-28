import SwiftUI

struct AppBar: View {
    let title: String
    var leadingButton: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
                .shadow(radius: 1)
            
            HStack {
                if leadingButton != nil {
                    Button(action: {
                        leadingButton?()
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 22))
                            .foregroundColor(.primary)
                    }
                    .frame(width: 44, height: 44)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .frame(height: 44)
    }
} 