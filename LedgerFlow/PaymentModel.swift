import Foundation

struct PaymentModel: Codable, Identifiable {
    let id: UUID
    let contributionId: UUID
    let participantId: UUID
    var amount: Double
    let timestamp: Date
    
    init(contributionId: UUID, participantId: UUID, amount: Double) {
        self.id = UUID()
        self.contributionId = contributionId
        self.participantId = participantId
        self.amount = amount
        self.timestamp = Date()
    }
}
