import SwiftUI
import Combine

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var selectedGroup = "All"
    @Published var selectedContribution = "All"
    @Published var selectedParticipant = "All"
    @Published var selectedPeriod: DateRangeFilter = .allTime
    @Published var availableGroups: [String] = ["All"]
    @Published var availableContributions: [String] = ["All"]
    @Published var availableParticipants: [String] = ["All"]
    
    func updateFilters(appStore: AppStore) {
        let groups = ["All"] + appStore.getUniqueGroupNames()
        availableGroups = groups
        
        let participants = ["All"] + appStore.getUniqueParticipantNames()
        availableParticipants = participants
        
        if !groups.contains(selectedGroup) {
            selectedGroup = "All"
        }
        
        if !participants.contains(selectedParticipant) {
            selectedParticipant = "All"
        }
        
        updateContributions(appStore: appStore)
    }
    
    func updateContributions(appStore: AppStore) {
        let filteredContributions: [String]
        
        if selectedGroup == "All" {
            filteredContributions = Array(Set(appStore.state.contributions.map { $0.groupName })).sorted()
        } else {
            filteredContributions = Array(Set(appStore.state.contributions
                .filter { $0.groupName == selectedGroup }
                .map { $0.groupName })).sorted()
        }
        
        availableContributions = ["All"] + filteredContributions
        
        if !availableContributions.contains(selectedContribution) {
            selectedContribution = "All"
        }
    }
}
