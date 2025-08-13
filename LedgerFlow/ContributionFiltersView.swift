import SwiftUI

struct ContributionFiltersView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: ThemeSpacing.md) {
            SearchFieldView(
                text: $viewModel.searchText,
                placeholder: "Search groups (min 2 characters)"
            )
            .padding(.horizontal, ThemeSpacing.md)
            
            VStack(spacing: ThemeSpacing.sm) {
                PillFilterControl(
                    options: ContributionStatus.allCases,
                    selection: $viewModel.selectedStatus,
                    displayName: { $0.rawValue }
                )
                
                PillFilterControl(
                    options: [DateRangeFilter.allTime, .thisMonth, .lastMonth],
                    selection: $viewModel.selectedPeriod,
                    displayName: { $0.rawValue }
                )
            }
            

        }

    }
}


