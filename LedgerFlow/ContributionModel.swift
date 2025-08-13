import Foundation

struct ContributionModel: Codable, Identifiable {
    let id: UUID
    var groupName: String
    var perPersonAmount: Double
    var participants: [ParticipantModel]
    var dueDate: Date?
    var createdAt: Date
    
    init(groupName: String, perPersonAmount: Double, participants: [ParticipantModel], dueDate: Date? = nil) {
        self.id = UUID()
        self.groupName = groupName
        self.perPersonAmount = perPersonAmount
        self.participants = participants
        self.dueDate = dueDate
        self.createdAt = Date()
    }
    
    var totalNeeded: Double {
        Double(participants.count) * perPersonAmount
    }
    
    var totalCollected: Double {
        participants.reduce(0) { $0 + $1.totalPaid }
    }
    
    var paidParticipantsCount: Int {
        participants.filter { $0.totalPaid >= perPersonAmount }.count
    }
    
    var status: ContributionStatus {
        let paidCount = paidParticipantsCount
        let totalCount = participants.count
        
        if paidCount == totalCount {
            return .allPaid
        } else if paidCount > 0 {
            return .partial
        } else {
            return .none
        }
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return Date() > dueDate && status != .allPaid
    }
}

enum ContributionStatus: String, CaseIterable, Codable {
    case all = "All"
    case allPaid = "All paid"
    case partial = "Partial"
    case none = "None"
}
