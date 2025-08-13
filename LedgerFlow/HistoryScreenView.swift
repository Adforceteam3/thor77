import SwiftUI

struct HistoryScreenView: View {
    @EnvironmentObject var appStore: AppStore
    @StateObject private var viewModel = HistoryViewModel()
    @State private var showPaymentDetail = false
    @State private var selectedPayment: PaymentModel?
    
    var body: some View {
        TabContentContainerView {
            VStack(spacing: ThemeSpacing.lg) {
                SectionHeaderView("Payment History", subtitle: "Track all payment activities")
                
                historyFilters
                
                if filteredPayments.isEmpty {
                    if appStore.state.payments.isEmpty {
                        EmptyStateView(
                            icon: "clock",
                            title: "No payment history",
                            subtitle: "Payments will appear here once they are recorded"
                        )
                    } else {
                        EmptyStateView(
                            icon: "line.3.horizontal.decrease.circle",
                            title: "No results for selected filters",
                            subtitle: "Try adjusting filters to see payments"
                        )
                    }
                } else {
                    LazyVStack(spacing: ThemeSpacing.sm) {
                        ForEach(filteredPayments) { payment in
                            PaymentRowView(payment: payment) {
                                selectedPayment = payment
                                showPaymentDetail = true
                            }
                        }
                    }
                    .padding(.horizontal, ThemeSpacing.md)
                }
                
                Spacer(minLength: 100)
            }
        }
        .sheet(isPresented: $showPaymentDetail) {
            if let payment = selectedPayment {
                PaymentDetailSheet(payment: payment)
            }
        }

        .onAppear {
            viewModel.updateFilters(appStore: appStore)
        }
    }
    
    private var historyFilters: some View {
        VStack(spacing: ThemeSpacing.sm) {
            // скрыли все узкие фильтры, оставляем только общие ниже
            
            PillFilterControl(
                options: [DateRangeFilter.allTime, .thisMonth, .lastMonth],
                selection: $viewModel.selectedPeriod,
                displayName: { $0.rawValue }
            )
        }
        .onChange(of: viewModel.selectedGroup) { _ in
            viewModel.updateContributions(appStore: appStore)
        }
    }
    
    private var filteredPayments: [PaymentModel] {
        appStore.filteredPayments(
            groupFilter: viewModel.selectedGroup == "All" ? nil : viewModel.selectedGroup,
            contributionFilter: viewModel.selectedContribution == "All" ? nil : viewModel.selectedContribution,
            participantFilter: viewModel.selectedParticipant == "All" ? nil : viewModel.selectedParticipant,
            dateRange: viewModel.selectedPeriod,
            customDateRange: nil
        )
    }
}
