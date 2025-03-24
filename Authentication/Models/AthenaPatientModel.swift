import Foundation

struct AthenaPatientRequest: Codable {
    let practiceId: String
    let reasonId: String
    let providerId: String
    let startDate: String
    let departmentId: String
    let patientId: String
    let appointmentId: String
    let appointmentTypeId: String
    let dob: String
    let lastName: String
    let firstName: String
    let address1: String
    let address2: String
    let assignedSexAtBirth: String
    let city: String
    let email: String
    let sex: String
    let startTime: String
    let mobilePhone: String
    
    enum CodingKeys: String, CodingKey {
        case practiceId = "practiceId"
        case reasonId = "reasonId"
        case providerId = "providerId"
        case startDate = "startDate"
        case departmentId = "departmentId"
        case patientId = "patientId"
        case appointmentId = "appointmentId"
        case appointmentTypeId = "appointmentTypeId"
        case dob = "dob"
        case lastName = "lastName"
        case firstName = "firstName"
        case address1 = "address1"
        case address2 = "address2"
        case assignedSexAtBirth = "assignedSexAtBirth"
        case city = "city"
        case email = "email"
        case sex = "sex"
        case startTime = "startTime"
        case mobilePhone = "mobilePhone"
    }
}

struct AthenaPatientResponse: Codable {
    let success: Bool
    let message: String?
    let data: [String: String]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        
        // Handle the data field which might contain different types
        if let dataContainer = try? container.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .data) {
            var dataDict = [String: String]()
            for key in dataContainer.allKeys {
                if let value = try? dataContainer.decode(String.self, forKey: key) {
                    dataDict[key.stringValue] = value
                }
            }
            data = dataDict.isEmpty ? nil : dataDict
        } else {
            data = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encodeIfPresent(message, forKey: .message)
        if let dataDict = data {
            var dataContainer = container.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .data)
            for (key, value) in dataDict {
                try dataContainer.encode(value, forKey: DynamicCodingKeys(stringValue: key)!)
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case data
    }
    
    struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
} 