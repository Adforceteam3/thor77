import SwiftUI
import Combine

@MainActor
class ContributionDetailViewModel: ObservableObject {
    @Published var currentContribution: ContributionModel?
    
    func updateContribution(_ contribution: ContributionModel, appStore: AppStore) {
        if let updated = appStore.state.contributions.first(where: { $0.id == contribution.id }) {
            currentContribution = updated
        } else {
            currentContribution = contribution
        }
    }
}
