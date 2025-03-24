import SwiftUI

struct HomeView: View {
    @Binding var isAuthenticated: Bool
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject var loginViewModel: LoginViewModel
    @State private var isDrawerOpen = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main Content
                VStack(spacing: 20) {
                    Image("CompanyLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                        .padding(.top, 40)
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            // Patient Form Fields
                            Group {
                                TextField("Practice ID", text: $viewModel.patientRequest.practiceId)
                                TextField("Reason ID", text: $viewModel.patientRequest.reasonId)
                                TextField("Provider ID", text: $viewModel.patientRequest.providerId)
                                TextField("Start Date", text: $viewModel.patientRequest.startDate)
                                TextField("Department ID", text: $viewModel.patientRequest.departmentId)
                                TextField("Patient ID", text: $viewModel.patientRequest.patientId)
                                TextField("Appointment ID", text: $viewModel.patientRequest.appointmentId)
                                TextField("Appointment Type ID", text: $viewModel.patientRequest.appointmentTypeId)
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            
                            Group {
                                TextField("DOB", text: $viewModel.patientRequest.dob)
                                TextField("Last Name", text: $viewModel.patientRequest.lastName)
                                TextField("First Name", text: $viewModel.patientRequest.firstName)
                                TextField("Address 1", text: $viewModel.patientRequest.address1)
                                TextField("Address 2", text: $viewModel.patientRequest.address2)
                                TextField("Assigned Sex at Birth", text: $viewModel.patientRequest.assignedSexAtBirth)
                                TextField("City", text: $viewModel.patientRequest.city)
                                TextField("Email", text: $viewModel.patientRequest.email)
                                TextField("Sex", text: $viewModel.patientRequest.sex)
                                TextField("Start Time", text: $viewModel.patientRequest.startTime)
                                TextField("Mobile Phone", text: $viewModel.patientRequest.mobilePhone)
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            
                            Button(action: {
                                Task {
                                    await viewModel.getPatientReasons()
                                }
                            }) {
                                Text("Get Patient Reasons")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                            
                            if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
                
                // Drawer
                GeometryReader { geometry in
                    HStack {
                        if isDrawerOpen {
                            VStack {
                                Text("Menu")
                                    .font(.title)
                                    .padding()
                                
                                Text(loginViewModel.loggedInUsername)
                                    .font(.headline)
                                    .padding()
                                
                                Spacer()
                                
                                Button(action: {
                                    Task {
                                        await viewModel.logout()
                                        loginViewModel.clearCredentials()
                                        isAuthenticated = false
                                    }
                                }) {
                                    Text("Logout")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                }
                                .padding(.bottom, 20)
                            }
                            .frame(width: geometry.size.width * 0.75)
                            .background(Color(.systemBackground))
                            .shadow(radius: 10)
                            
                            Spacer()
                        }
                    }
                }
                .animation(.default, value: isDrawerOpen)
            }
            .navigationBarTitle("Home", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                isDrawerOpen.toggle()
            }) {
                Image(systemName: "line.horizontal.3")
                    .imageScale(.large)
            })
        }
    }
}

#Preview {
    HomeView(isAuthenticated: .constant(true), loginViewModel: LoginViewModel())
} 
