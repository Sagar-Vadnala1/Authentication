import SwiftUI

struct ProfileView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Profile Image
            Image(systemName: "person.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.blue)
                .padding(.top, 32)
            
            // Profile Info
            VStack(spacing: 8) {
                Text("Dr. \(loginViewModel.loggedInUsername)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Medical Professional")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Stats
            HStack(spacing: 32) {
                VStack {
                    Text("124")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Patients")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("1.2k")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Diagnoses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("98%")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Accuracy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical)
            
            // Additional Info
            List {
                Section(header: Text("Personal Information")) {
                    InfoRow(icon: "envelope.fill", title: "Email", value: "\(loginViewModel.loggedInUsername)@hikigai.com")
                    InfoRow(icon: "phone.fill", title: "Phone", value: "+1 (555) 123-4567")
                    InfoRow(icon: "building.2.fill", title: "Department", value: "General Medicine")
                    InfoRow(icon: "location.fill", title: "Location", value: "New York, NY")
                }
                
                Section(header: Text("App Settings")) {
                    Toggle("Push Notifications", isOn: .constant(true))
                    Toggle("Email Notifications", isOn: .constant(false))
                    Toggle("Dark Mode", isOn: .constant(false))
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.primary)
        }
    }
} 