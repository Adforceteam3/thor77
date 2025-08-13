import SwiftUI
import Combine

@MainActor
class AnalyticsViewModel: ObservableObject {
    @Published var selectedPeriod: DateRangeFilter = .allTime
    @Published var selectedGroup = "All"

    @Published var availableGroups: [String] = ["All"]
    @Published var candlestickData: [CandlestickPoint] = []
    @Published var snapshot = AnalyticsSnapshot(date: Date(), totalCollected: 0, activeContributions: 0, paymentsCount: 0)
    @Published var topGroups: [GroupAnalytics] = []
    
    var hasData: Bool {
        snapshot.totalCollected > 0 || snapshot.paymentsCount > 0 || snapshot.activeContributions > 0 || !topGroups.isEmpty
    }
    
    func updateAnalytics(appStore: AppStore) {
        let groups = ["All"] + appStore.getUniqueGroupNames()
        availableGroups = groups
        
        if !groups.contains(selectedGroup) {
            selectedGroup = "All"
        }
        
        let (candlesticks, analyticsSnapshot) = appStore.generateAnalyticsData(
            dateRange: selectedPeriod,
            customDateRange: nil,
            groupFilter: selectedGroup == "All" ? nil : selectedGroup
        )
        
        candlestickData = candlesticks
        snapshot = analyticsSnapshot
        
        generateTopGroups(appStore: appStore)
    }
    
    private func generateTopGroups(appStore: AppStore) {
        let filteredPayments = appStore.filteredPayments(
            groupFilter: selectedGroup == "All" ? nil : selectedGroup,
            contributionFilter: nil,
            participantFilter: nil,
            dateRange: selectedPeriod,
            customDateRange: nil
        )
        
        let totalAmount = filteredPayments.reduce(0) { $0 + $1.amount }
        
        let groupTotals = Dictionary(grouping: filteredPayments) { payment in
            appStore.state.contributions.first { $0.id == payment.contributionId }?.groupName ?? ""
        }.mapValues { payments in
            payments.reduce(0) { $0 + $1.amount }
        }
        
        topGroups = groupTotals.map { name, amount in
            GroupAnalytics(
                name: name,
                amount: amount,
                percentage: totalAmount > 0 ? (amount / totalAmount) * 100 : 0
            )
        }
        .sorted { $0.amount > $1.amount }
        .prefix(5)
        .map { $0 }
    }
}

struct GroupAnalytics: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let percentage: Double
}
