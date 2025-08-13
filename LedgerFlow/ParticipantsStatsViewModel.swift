import SwiftUI
import Combine

@MainActor
class ParticipantsStatsViewModel: ObservableObject {
    @Published var selectedGroup = "All"
    @Published var selectedPeriod: DateRangeFilter = .allTime
    @Published var overdueThreshold = 7
    @Published var availableGroups: [String] = ["All"]
    
    @Published var topResponsible: [ResponsibleParticipant] = []
    @Published var attentionNeeded: [AttentionParticipant] = []
    @Published var totalContributions: [ContributionParticipant] = []
    
    var hasData: Bool {
        !topResponsible.isEmpty || !attentionNeeded.isEmpty || !totalContributions.isEmpty
    }
    
    func updateStatistics(appStore: AppStore) {
        let groups = ["All"] + appStore.getUniqueGroupNames()
        availableGroups = groups
        
        if !groups.contains(selectedGroup) {
            selectedGroup = "All"
        }
        
        let filteredContributions = appStore.state.contributions.filter { contribution in
            if selectedGroup == "All" {
                return true
            } else {
                return contribution.groupName == selectedGroup
            }
        }
        
        let periodRange = selectedPeriod.dateRange()
        let filteredPayments = appStore.state.payments.filter { payment in
            guard let range = periodRange else { return true }
            return payment.timestamp >= range.start && payment.timestamp <= range.end
        }
        
        generateTopResponsible(contributions: filteredContributions, payments: filteredPayments)
        generateAttentionNeeded(contributions: filteredContributions)
        generateTotalContributions(payments: filteredPayments, contributions: filteredContributions)
    }
    
    private func generateTopResponsible(contributions: [ContributionModel], payments: [PaymentModel]) {
        var participantStats: [String: ResponsibleParticipant] = [:]
        
        for contribution in contributions {
            for participant in contribution.participants {
                let participantPayments = payments.filter { $0.participantId == participant.id }
                
                var onTimePayments = 0
                var totalPayments = participantPayments.count
                
                if let dueDate = contribution.dueDate {
                    onTimePayments = participantPayments.filter { $0.timestamp <= dueDate }.count
                } else {
                    onTimePayments = totalPayments
                }
                
                let onTimePercentage = totalPayments > 0 ? Double(onTimePayments) / Double(totalPayments) * 100 : 100
                let totalAmount = participantPayments.reduce(0) { $0 + $1.amount }
                let averageContribution = totalPayments > 0 ? totalAmount / Double(totalPayments) : 0
                
                if let existing = participantStats[participant.name] {
                    participantStats[participant.name] = ResponsibleParticipant(
                        name: participant.name,
                        onTimePercentage: (existing.onTimePercentage + onTimePercentage) / 2,
                        averageContribution: (existing.averageContribution + averageContribution) / 2,
                        totalGiven: existing.totalGiven + totalAmount
                    )
                } else {
                    participantStats[participant.name] = ResponsibleParticipant(
                        name: participant.name,
                        onTimePercentage: onTimePercentage,
                        averageContribution: averageContribution,
                        totalGiven: totalAmount
                    )
                }
            }
        }
        
        topResponsible = Array(participantStats.values)
            .sorted { $0.onTimePercentage > $1.onTimePercentage }
            .prefix(10)
            .map { $0 }
    }
    
    private func generateAttentionNeeded(contributions: [ContributionModel]) {
        var participantAttention: [String: AttentionParticipant] = [:]
        
        for contribution in contributions {
            guard let dueDate = contribution.dueDate else { continue }
            let daysPastDue = Calendar.current.dateComponents([.day], from: dueDate, to: Date()).day ?? 0
            
            for participant in contribution.participants {
                let remainingAmount = max(0, contribution.perPersonAmount - participant.totalPaid)
                
                if remainingAmount > 0 && daysPastDue > overdueThreshold {
                    if let existing = participantAttention[participant.name] {
                        participantAttention[participant.name] = AttentionParticipant(
                            name: participant.name,
                            overdueCount: existing.overdueCount + 1,
                            totalDebt: existing.totalDebt + remainingAmount
                        )
                    } else {
                        participantAttention[participant.name] = AttentionParticipant(
                            name: participant.name,
                            overdueCount: 1,
                            totalDebt: remainingAmount
                        )
                    }
                }
            }
        }
        
        attentionNeeded = Array(participantAttention.values)
            .sorted { $0.totalDebt > $1.totalDebt }
            .prefix(10)
            .map { $0 }
    }
    
    private func generateTotalContributions(payments: [PaymentModel], contributions: [ContributionModel]) {
        var participantTotals: [String: Double] = [:]
        
        for payment in payments {
            if let contribution = contributions.first(where: { $0.id == payment.contributionId }),
               let participant = contribution.participants.first(where: { $0.id == payment.participantId }) {
                participantTotals[participant.name, default: 0] += payment.amount
            }
        }
        
        let maxAmount = participantTotals.values.max() ?? 1
        
        totalContributions = participantTotals.map { name, amount in
            ContributionParticipant(
                name: name,
                totalAmount: amount,
                percentage: (amount / maxAmount) * 100
            )
        }
        .sorted { $0.totalAmount > $1.totalAmount }
        .prefix(10)
        .map { $0 }
    }
}

struct ResponsibleParticipant: Identifiable {
    let id = UUID()
    let name: String
    let onTimePercentage: Double
    let averageContribution: Double
    let totalGiven: Double
}

struct AttentionParticipant: Identifiable {
    let id = UUID()
    let name: String
    let overdueCount: Int
    let totalDebt: Double
}

struct ContributionParticipant: Identifiable {
    let id = UUID()
    let name: String
    let totalAmount: Double
    let percentage: Double
}
