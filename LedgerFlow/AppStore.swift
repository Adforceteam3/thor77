import Foundation
import SwiftUI

@MainActor
class AppStore: ObservableObject {
    @Published var state = AppState()
    @Published var showOnboarding = false
    @Published var selectedTab: AppTab = .home
    
    private let storage = FileStorage.shared
    private let stateFilename = "app_state"
    
    init() {
        Task {
            await loadState()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showOnboarding = !self.state.hasCompletedOnboarding
            }
        }
    }
    
    func loadState() async {
        do {
            if storage.exists(stateFilename) {
                let loadedState = try await storage.load(AppState.self, from: stateFilename)
                state = loadedState
                selectedTab = AppTab(rawValue: state.selectedTabIndex) ?? .home
            }
        } catch {
            print("Failed to load state: \(error)")
        }
    }
    
    func saveState() async {
        do {
            state.selectedTabIndex = selectedTab.rawValue
            try await storage.save(state, to: stateFilename)
        } catch {
            print("Failed to save state: \(error)")
        }
    }
    
    func completeOnboarding() {
        state.hasCompletedOnboarding = true
        showOnboarding = false
        Task {
            await saveState()
        }
    }
    
    func createContribution(_ contribution: ContributionModel) {
        state.contributions.append(contribution)
        Task {
            await saveState()
        }
    }
    
    func updateContribution(_ contribution: ContributionModel) {
        if let index = state.contributions.firstIndex(where: { $0.id == contribution.id }) {
            state.contributions[index] = contribution
            Task {
                await saveState()
            }
        }
    }
    
    func deleteContribution(_ contributionId: UUID) {
        state.contributions.removeAll { $0.id == contributionId }
        state.payments.removeAll { $0.contributionId == contributionId }
        Task {
            await saveState()
        }
    }
    
    func addPayment(_ payment: PaymentModel) {
        state.payments.append(payment)
        
        if let contributionIndex = state.contributions.firstIndex(where: { $0.id == payment.contributionId }),
           let participantIndex = state.contributions[contributionIndex].participants.firstIndex(where: { $0.id == payment.participantId }) {
            state.contributions[contributionIndex].participants[participantIndex].totalPaid += payment.amount
        }
        
        Task {
            await saveState()
        }
    }
    
    func updatePayment(_ payment: PaymentModel, oldAmount: Double) {
        if let index = state.payments.firstIndex(where: { $0.id == payment.id }) {
            state.payments[index] = payment
            
            let amountDifference = payment.amount - oldAmount
            
            if let contributionIndex = state.contributions.firstIndex(where: { $0.id == payment.contributionId }),
               let participantIndex = state.contributions[contributionIndex].participants.firstIndex(where: { $0.id == payment.participantId }) {
                state.contributions[contributionIndex].participants[participantIndex].totalPaid += amountDifference
            }
            
            Task {
                await saveState()
            }
        }
    }
    
    func deletePayment(_ paymentId: UUID) {
        if let payment = state.payments.first(where: { $0.id == paymentId }) {
            if let contributionIndex = state.contributions.firstIndex(where: { $0.id == payment.contributionId }),
               let participantIndex = state.contributions[contributionIndex].participants.firstIndex(where: { $0.id == payment.participantId }) {
                state.contributions[contributionIndex].participants[participantIndex].totalPaid -= payment.amount
            }
            
            state.payments.removeAll { $0.id == paymentId }
            Task {
                await saveState()
            }
        }
    }
    
    func filteredContributions(searchText: String, groupFilter: String?, statusFilter: ContributionStatus, dateRange: DateRangeFilter, customDateRange: CustomDateRange?) -> [ContributionModel] {
        var filtered = state.contributions
        
        if !searchText.isEmpty && searchText.count >= 2 {
            filtered = filtered.filter { $0.groupName.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let groupFilter = groupFilter, !groupFilter.isEmpty {
            filtered = filtered.filter { $0.groupName == groupFilter }
        }
        
        if statusFilter != .all {
            filtered = filtered.filter { $0.status == statusFilter }
        }
        
        if let range = dateRange.dateRange() {
            filtered = filtered.filter { contribution in
                contribution.createdAt >= range.start && contribution.createdAt <= range.end
            }
        } else if dateRange == .custom, let customRange = customDateRange, customRange.isValid {
            filtered = filtered.filter { contribution in
                contribution.createdAt >= customRange.startDate && contribution.createdAt <= customRange.endDate
            }
        }
        
        return filtered.sorted { $0.createdAt > $1.createdAt }
    }
    
    func filteredPayments(groupFilter: String?, contributionFilter: String?, participantFilter: String?, dateRange: DateRangeFilter, customDateRange: CustomDateRange?) -> [PaymentModel] {
        var filtered = state.payments
        
        if let range = dateRange.dateRange() {
            filtered = filtered.filter { payment in
                payment.timestamp >= range.start && payment.timestamp <= range.end
            }
        } else if dateRange == .custom, let customRange = customDateRange, customRange.isValid {
            filtered = filtered.filter { payment in
                payment.timestamp >= customRange.startDate && payment.timestamp <= customRange.endDate
            }
        }
        
        if let groupFilter = groupFilter, !groupFilter.isEmpty {
            let contributionIds = state.contributions.filter { $0.groupName == groupFilter }.map { $0.id }
            filtered = filtered.filter { contributionIds.contains($0.contributionId) }
        }
        
        if let contributionFilter = contributionFilter, !contributionFilter.isEmpty {
            if let contribution = state.contributions.first(where: { $0.groupName == contributionFilter }) {
                filtered = filtered.filter { $0.contributionId == contribution.id }
            }
        }
        
        if let participantFilter = participantFilter, !participantFilter.isEmpty {
            let participantIds = state.contributions.flatMap { $0.participants }.filter { $0.name == participantFilter }.map { $0.id }
            filtered = filtered.filter { participantIds.contains($0.participantId) }
        }
        
        return filtered.sorted { $0.timestamp > $1.timestamp }
    }
    
    func generateAnalyticsData(dateRange: DateRangeFilter, customDateRange: CustomDateRange?, groupFilter: String?) -> ([CandlestickPoint], AnalyticsSnapshot) {
        var filteredPayments = state.payments
        
        if let range = dateRange.dateRange() {
            filteredPayments = filteredPayments.filter { $0.timestamp >= range.start && $0.timestamp <= range.end }
        } else if dateRange == .custom, let customRange = customDateRange, customRange.isValid {
            filteredPayments = filteredPayments.filter { $0.timestamp >= customRange.startDate && $0.timestamp <= customRange.endDate }
        }
        
        if let groupFilter = groupFilter, !groupFilter.isEmpty {
            let contributionIds = state.contributions.filter { $0.groupName == groupFilter }.map { $0.id }
            filteredPayments = filteredPayments.filter { contributionIds.contains($0.contributionId) }
        }
        
        let totalCollected = filteredPayments.reduce(0) { $0 + $1.amount }
        let activeContributions = state.contributions.filter { $0.status != .allPaid }.count
        
        let candlestickData = generateCandlestickData(from: filteredPayments, dateRange: dateRange)
        
        let snapshot = AnalyticsSnapshot(
            date: Date(),
            totalCollected: totalCollected,
            activeContributions: activeContributions,
            paymentsCount: filteredPayments.count,
            topGroupName: findTopGroup(from: filteredPayments)?.0,
            topGroupAmount: findTopGroup(from: filteredPayments)?.1 ?? 0
        )
        
        return (candlestickData, snapshot)
    }
    
    private func generateCandlestickData(from payments: [PaymentModel], dateRange: DateRangeFilter) -> [CandlestickPoint] {
        let calendar = Calendar.current
        let groupedPayments = Dictionary(grouping: payments) { payment in
            calendar.startOfDay(for: payment.timestamp)
        }
        
        let mapped = groupedPayments.map { date, dayPayments in
            let amounts = dayPayments.map { $0.amount }.sorted()
            let open = amounts.first ?? 0
            let close = amounts.last ?? 0
            let high = amounts.max() ?? 0
            let low = amounts.min() ?? 0
            
            return CandlestickPoint(
                date: date,
                open: open,
                high: high,
                low: low,
                close: close,
                volume: dayPayments.count
            )
        }.sorted { $0.date < $1.date }
        
        return mapped
    }

    
    private func findTopGroup(from payments: [PaymentModel]) -> (String, Double)? {
        let groupTotals = Dictionary(grouping: payments) { payment in
            state.contributions.first { $0.id == payment.contributionId }?.groupName ?? ""
        }.mapValues { $0.reduce(0) { $0 + $1.amount } }
        
        return groupTotals.max { $0.value < $1.value }.map { ($0.key, $0.value) }
    }
    
    func getUniqueGroupNames() -> [String] {
        Array(Set(state.contributions.map { $0.groupName })).sorted()
    }
    
    func getUniqueParticipantNames() -> [String] {
        let allParticipants = state.contributions.flatMap { $0.participants.map { $0.name } }
        return Array(Set(allParticipants)).sorted()
    }
    
    func switchToTab(_ tab: AppTab) {
        selectedTab = tab
        Task {
            await saveState()
        }
    }
}
