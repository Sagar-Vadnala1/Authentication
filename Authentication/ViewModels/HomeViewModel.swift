import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var patientRequest = PatientRequestState()
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    func logout() async {
        do {
            try await NetworkService.shared.logout()
        } catch {
            print("Logout error: \(error)")
        }
    }
    
    func getPatientReasons() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = AthenaPatientRequest(
                practiceId: patientRequest.practiceId,
                reasonId: patientRequest.reasonId,
                providerId: patientRequest.providerId,
                startDate: patientRequest.startDate,
                departmentId: patientRequest.departmentId,
                patientId: patientRequest.patientId,
                appointmentId: patientRequest.appointmentId,
                appointmentTypeId: patientRequest.appointmentTypeId,
                dob: patientRequest.dob,
                lastName: patientRequest.lastName,
                firstName: patientRequest.firstName,
                address1: patientRequest.address1,
                address2: patientRequest.address2,
                assignedSexAtBirth: patientRequest.assignedSexAtBirth,
                city: patientRequest.city,
                email: patientRequest.email,
                sex: patientRequest.sex,
                startTime: patientRequest.startTime,
                mobilePhone: patientRequest.mobilePhone
            )
            
            let response = try await NetworkService.shared.getAthenaPatientReasons(request)
            if response.success {
                errorMessage = "Patient reasons retrieved successfully"
            } else {
                errorMessage = response.message ?? "Failed to get patient reasons"
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

class PatientRequestState: ObservableObject {
    @Published var practiceId = ""
    @Published var reasonId = ""
    @Published var providerId = ""
    @Published var startDate = ""
    @Published var departmentId = ""
    @Published var patientId = ""
    @Published var appointmentId = ""
    @Published var appointmentTypeId = ""
    @Published var dob = ""
    @Published var lastName = ""
    @Published var firstName = ""
    @Published var address1 = ""
    @Published var address2 = ""
    @Published var assignedSexAtBirth = ""
    @Published var city = ""
    @Published var email = ""
    @Published var sex = ""
    @Published var startTime = ""
    @Published var mobilePhone = ""
} 