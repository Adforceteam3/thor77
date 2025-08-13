import SwiftUI

struct ParticipantsStatsScreenView: View {
    @EnvironmentObject var appStore: AppStore
    @StateObject private var viewModel = ParticipantsStatsViewModel()
    
    var body: some View {
        TabContentContainerView {
            VStack(spacing: ThemeSpacing.lg) {
                SectionHeaderView("Participant Statistics", subtitle: "Performance and contribution insights")
                
                statsFilters
                
                if viewModel.hasData {
                    VStack(spacing: ThemeSpacing.xl) {
                        topResponsibleSection
                        attentionNeededSection
                        totalContributionSection
                    }
                } else {
                    if appStore.state.payments.isEmpty {
                        EmptyStateView(
                            icon: "person.3",
                            title: "No participant data",
                            subtitle: "Statistics will appear here once you have contributions and payments"
                        )
                    } else {
                        EmptyStateView(
                            icon: "line.3.horizontal.decrease.circle",
                            title: "No results for selected filters",
                            subtitle: "Try adjusting filters to see statistics"
                        )
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
        .onAppear {
            updateStatistics()
        }
        .onChange(of: viewModel.selectedGroup) { _ in updateStatistics() }
        .onChange(of: viewModel.selectedPeriod) { _ in updateStatistics() }
        .onChange(of: viewModel.overdueThreshold) { _ in updateStatistics() }
    }
    
    private var statsFilters: some View {
        VStack(spacing: ThemeSpacing.sm) {
            // групповой фильтр скрыт: оставляем период и порог просрочки
            
            PillFilterControl(
                options: [DateRangeFilter.allTime, .last30Days, .last90Days],
                selection: $viewModel.selectedPeriod,
                displayName: { $0.rawValue }
            )
            
            HStack {
                Text("Overdue threshold:")
                    .font(ThemeFonts.subheadline)
                    .foregroundColor(ThemeColors.gray)
                
                Spacer()
                
                Picker("Days", selection: $viewModel.overdueThreshold) {
                    ForEach(1...30, id: \.self) { days in
                        Text("\(days) days").tag(days)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(ThemeColors.primary)
            }
            .padding(.horizontal, ThemeSpacing.md)
        }
    }
    
    private var topResponsibleSection: some View {
        VStack(alignment: .leading, spacing: ThemeSpacing.md) {
            Text("Top Responsible")
                .font(ThemeFonts.title2)
                .foregroundColor(ThemeColors.primary)
                .padding(.horizontal, ThemeSpacing.md)
            
            ResponsibleTopListView(participants: viewModel.topResponsible)
        }
    }
    
    private var attentionNeededSection: some View {
        VStack(alignment: .leading, spacing: ThemeSpacing.md) {
            Text("Attention Needed")
                .font(ThemeFonts.title2)
                .foregroundColor(ThemeColors.primary)
                .padding(.horizontal, ThemeSpacing.md)
            
            AttentionNeededListView(participants: viewModel.attentionNeeded)
        }
    }
    
    private var totalContributionSection: some View {
        VStack(alignment: .leading, spacing: ThemeSpacing.md) {
            Text("Total Contribution Ranking")
                .font(ThemeFonts.title2)
                .foregroundColor(ThemeColors.primary)
                .padding(.horizontal, ThemeSpacing.md)
            
            TotalContributionBarsView(participants: viewModel.totalContributions)
        }
    }
    
    private func updateStatistics() {
        viewModel.updateStatistics(appStore: appStore)
    }
}
