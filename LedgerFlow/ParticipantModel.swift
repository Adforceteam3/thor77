import Foundation

struct ParticipantModel: Codable, Identifiable {
    let id: UUID
    var name: String
    var totalPaid: Double
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.totalPaid = 0
    }
    
    func paymentStatus(requiredAmount: Double) -> ParticipantPaymentStatus {
        if totalPaid >= requiredAmount {
            return .paid
        } else if totalPaid > 0 {
            return .partial
        } else {
            return .notPaid
        }
    }
    
    func remainingAmount(requiredAmount: Double) -> Double {
        max(0, requiredAmount - totalPaid)
    }
}

enum ParticipantPaymentStatus: String, CaseIterable {
    case paid = "Paid"
    case partial = "Partial"
    case notPaid = "Not paid"
    
    var color: String {
        switch self {
        case .paid: return "green"
        case .partial: return "orange"
        case .notPaid: return "red"
        }
    }
}
