import SwiftUI

struct HomeScreenView: View {
    @EnvironmentObject var appStore: AppStore
    @StateObject private var viewModel = HomeViewModel()
    @State private var showCreateSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                  TabContentContainerView {
                      VStack(spacing: ThemeSpacing.lg) {
                        SectionHeaderView("Team Contributions", subtitle: "Who paid, who hasn't")
                    
                          ContributionFiltersView(viewModel: viewModel)
                    
                          if filteredContributions.isEmpty {
                        if appStore.state.contributions.isEmpty {
                            EmptyStateView(
                                icon: "person.3.sequence",
                                title: "No active contributions",
                                subtitle: "Create your first group contribution to get started tracking payments",
                                buttonTitle: "Create Contribution",
                                buttonAction: { showCreateSheet = true }
                            )
                          } else {
                            EmptyStateView(
                                icon: "line.3.horizontal.decrease.circle",
                                title: "No results for selected filters",
                                subtitle: "Try adjusting filters to see contributions"
                            )
                          }
                    } else {
                        LazyVStack(spacing: ThemeSpacing.md) {
                            ForEach(filteredContributions) { contribution in
                                NavigationLink(destination: ContributionDetailScreenView(contribution: contribution)) {
                                    ContributionCardView(contribution: contribution)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, ThemeSpacing.md)
                    }
                    
                          Spacer(minLength: 100)
                      }
                  }
                  
                Button {
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(ThemeFonts.title2)
                        .foregroundColor(ThemeColors.white)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(ThemeColors.primary))
                        .shadow(color: ThemeColors.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 110)
            }
        }
        .fullScreenCover(isPresented: $showCreateSheet) {
            CreateContributionSheet()
        }
        .onAppear {
            viewModel.updateFilters(appStore: appStore)
        }
    }
    
    private var filteredContributions: [ContributionModel] {
        appStore.filteredContributions(
            searchText: viewModel.searchText,
            groupFilter: viewModel.selectedGroup == "All" ? nil : viewModel.selectedGroup,
            statusFilter: viewModel.selectedStatus,
            dateRange: viewModel.selectedPeriod,
            customDateRange: nil
        )
    }
}
