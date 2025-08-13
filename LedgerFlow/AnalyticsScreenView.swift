import SwiftUI

struct AnalyticsScreenView: View {
    @EnvironmentObject var appStore: AppStore
    @StateObject private var viewModel = AnalyticsViewModel()
    
    var body: some View {
        TabContentContainerView {
            VStack(spacing: ThemeSpacing.lg) {
                SectionHeaderView("Analytics", subtitle: "Payment insights and trends")
                
                analyticsFilters
                
                if viewModel.hasData {
                    kpiCards
                    
                    if !viewModel.candlestickData.isEmpty {
                        candlestickChart
                    } else {
                        noCandlesPlaceholder
                    }
                    
                    topGroupsSection
                } else {
                    EmptyStateView(
                        icon: "chart.bar",
                        title: "No data for selected period",
                        subtitle: "Adjust your filters to see analytics or add some payments to get started"
                    )
                }
                
                Spacer(minLength: 100)
            }
        }
        .onAppear {
            updateAnalytics()
        }
        .onChange(of: viewModel.selectedPeriod) { _ in updateAnalytics() }
        .onChange(of: viewModel.selectedGroup) { _ in updateAnalytics() }

    }
    
    private var analyticsFilters: some View {
        VStack(spacing: ThemeSpacing.sm) {
            PillFilterControl(
                options: [DateRangeFilter.allTime, .last7Days, .last30Days, .last90Days],
                selection: $viewModel.selectedPeriod,
                displayName: { $0.rawValue }
            )
            
            // общий фильтр групп больше не показываем, только период
        }
    }
    
    private var kpiCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ThemeSpacing.md) {
                KPICard(
                    title: "Total Collected",
                    value: viewModel.snapshot.totalCollected.currencyFormatted,
                    icon: "dollarsign.circle.fill",
                    color: ThemeColors.success
                )
                
                KPICard(
                    title: "Active Contributions",
                    value: "\(viewModel.snapshot.activeContributions)",
                    icon: "person.3.fill",
                    color: ThemeColors.primary
                )
                
                KPICard(
                    title: "Total Payments",
                    value: "\(viewModel.snapshot.paymentsCount)",
                    icon: "creditcard.fill",
                    color: ThemeColors.accent
                )
                
                if let topGroup = viewModel.snapshot.topGroupName {
                    KPICard(
                        title: "Top Group",
                        value: topGroup,
                        subtitle: viewModel.snapshot.topGroupAmount.currencyFormatted,
                        icon: "crown.fill",
                        color: ThemeColors.warning
                    )
                }
            }
            .padding(.horizontal, ThemeSpacing.md)
        }
    }
    
    private var candlestickChart: some View {
        VStack(alignment: .leading, spacing: ThemeSpacing.md) {
            Text("Payment Trends")
                .font(ThemeFonts.headline)
                .foregroundColor(ThemeColors.primary)
                .padding(.horizontal, ThemeSpacing.md)
            
            if !viewModel.candlestickData.isEmpty {
                CandlestickChartView(data: viewModel.candlestickData)
                    .frame(height: 200)
                    .padding(.horizontal, ThemeSpacing.md)
            } else {
                Text("No payment data for chart")
                    .font(ThemeFonts.body)
                    .foregroundColor(ThemeColors.gray)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                            .fill(ThemeColors.lightGray)
                    )
                    .padding(.horizontal, ThemeSpacing.md)
            }
        }
    }
    
    private var noCandlesPlaceholder: some View {
        VStack(alignment: .leading, spacing: ThemeSpacing.md) {
            Text("Payment Trends")
                .font(ThemeFonts.headline)
                .foregroundColor(ThemeColors.primary)
                .padding(.horizontal, ThemeSpacing.md)
            
            VStack(spacing: ThemeSpacing.sm) {
                Text("No payments yet")
                    .font(ThemeFonts.body)
                    .foregroundColor(ThemeColors.gray)
                Text("Add payments to see candlestick chart")
                    .font(ThemeFonts.caption1)
                    .foregroundColor(ThemeColors.gray)
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                    .fill(ThemeColors.lightGray)
            )
            .padding(.horizontal, ThemeSpacing.md)
        }
    }
    
    private var topGroupsSection: some View {
        VStack(alignment: .leading, spacing: ThemeSpacing.md) {
            Text("Top Groups")
                .font(ThemeFonts.headline)
                .foregroundColor(ThemeColors.primary)
                .padding(.horizontal, ThemeSpacing.md)
            
            TopGroupsListView(groups: viewModel.topGroups)
        }
    }
    
    private func updateAnalytics() {
        viewModel.updateAnalytics(appStore: appStore)
    }
}

struct KPICard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let color: Color
    
    init(title: String, value: String, subtitle: String? = nil, icon: String, color: Color) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: ThemeSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(ThemeFonts.title3)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: ThemeSpacing.xs) {
                Text(value)
                    .font(ThemeFonts.title3)
                    .foregroundColor(ThemeColors.primary)
                    .fontWeight(.bold)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(ThemeFonts.caption1)
                        .foregroundColor(ThemeColors.gray)
                }
                
                Text(title)
                    .font(ThemeFonts.caption1)
                    .foregroundColor(ThemeColors.gray)
            }
        }
        .padding(ThemeSpacing.md)
        .frame(width: 140)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                .fill(ThemeColors.white)
                .shadow(color: ThemeColors.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}
