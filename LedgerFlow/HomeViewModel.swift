import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedGroup = "All"
    @Published var selectedStatus: ContributionStatus = .all
    @Published var selectedPeriod: DateRangeFilter = .allTime
    @Published var availableGroups: [String] = ["All"]
    
    func updateFilters(appStore: AppStore) {
        let groups = ["All"] + appStore.getUniqueGroupNames()
        availableGroups = groups
        
        if !groups.contains(selectedGroup) {
            selectedGroup = "All"
        }
    }
    
    func clearFilters() {
        searchText = ""
        selectedGroup = "All"
        selectedStatus = .all
        selectedPeriod = .allTime
    }
}
