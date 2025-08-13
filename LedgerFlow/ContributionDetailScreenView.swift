import SwiftUI

struct ContributionDetailScreenView: View {
    let contribution: ContributionModel
    @EnvironmentObject var appStore: AppStore
    @StateObject private var viewModel = ContributionDetailViewModel()
    @State private var selectedParticipant: ParticipantModel?
    @State private var showBulkPaymentSheet = false
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            ScrollView {
                VStack(spacing: ThemeSpacing.lg) {
                    contributionHeader
                    
                    if contribution.status == .allPaid {
                        completedBanner
                    } else if contribution.status == .partial {
                        partialBanner
                    }
                    
                    participantsSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 0)
            }
        }
        .navigationBarBackButtonHidden(false)
        .fullScreenCover(item: $selectedParticipant) { participant in
            MarkPaymentSheet(
                contribution: contribution,
                participant: participant
            )
        }
        .fullScreenCover(isPresented: $showBulkPaymentSheet) {
            BulkPaymentSheet(contribution: contribution)
        }
        .onAppear {
            viewModel.updateContribution(contribution, appStore: appStore)
        }
    }
    
    private var contributionHeader: some View {
        VStack(spacing: ThemeSpacing.md) {
            VStack(alignment: .leading, spacing: ThemeSpacing.sm) {
                Text(contribution.groupName)
                    .font(ThemeFonts.title1)
                    .foregroundColor(ThemeColors.primary)
                
                HStack {
                    Text("\(contribution.perPersonAmount.currencyFormatted) per participant")
                        .font(ThemeFonts.headline)
                        .foregroundColor(ThemeColors.gray)
                    
                    Spacer()
                    
                    Text("\(contribution.participants.count) members")
                        .font(ThemeFonts.headline)
                        .foregroundColor(ThemeColors.gray)
                }
                
                if let dueDate = contribution.dueDate {
                    HStack {
                        Text("Due: \(DateFormatter.shortDate.string(from: dueDate))")
                            .font(ThemeFonts.subheadline)
                            .foregroundColor(contribution.isOverdue ? ThemeColors.danger : ThemeColors.gray)
                        
                        if contribution.isOverdue {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(ThemeFonts.caption1)
                                .foregroundColor(ThemeColors.danger)
                        }
                        
                        Spacer()
                    }
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: ThemeSpacing.xs) {
                    Text("Collected")
                        .font(ThemeFonts.caption1)
                        .foregroundColor(ThemeColors.gray)
                    Text(contribution.totalCollected.currencyFormatted)
                        .font(ThemeFonts.title3)
                        .foregroundColor(ThemeColors.success)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: ThemeSpacing.xs) {
                    Text("Needed")
                        .font(ThemeFonts.caption1)
                        .foregroundColor(ThemeColors.gray)
                    Text(contribution.totalNeeded.currencyFormatted)
                        .font(ThemeFonts.title3)
                        .foregroundColor(ThemeColors.primary)
                        .fontWeight(.bold)
                }
            }
            
            StatusIndicator(status: contribution.status, isOverdue: contribution.isOverdue)
        }
        .padding(ThemeSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                .fill(ThemeColors.white)
                .shadow(color: ThemeColors.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, ThemeSpacing.md)
    }
    
    private var completedBanner: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .font(ThemeFonts.title3)
                .foregroundColor(ThemeColors.success)
            
            Text("Collection completed")
                .font(ThemeFonts.headline)
                .foregroundColor(ThemeColors.success)
            
            Spacer()
        }
        .padding(ThemeSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                .fill(ThemeColors.success.opacity(0.1))
        )
        .padding(.horizontal, ThemeSpacing.md)
    }
    
    private var partialBanner: some View {
        VStack(alignment: .leading, spacing: ThemeSpacing.sm) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(ThemeFonts.body)
                    .foregroundColor(ThemeColors.warning)
                
                Text("Remaining: \((contribution.totalNeeded - contribution.totalCollected).currencyFormatted)")
                    .font(ThemeFonts.headline)
                    .foregroundColor(ThemeColors.warning)
                
                Spacer()
            }
            
            Text("\(contribution.participants.count - contribution.paidParticipantsCount) participants pending")
                .font(ThemeFonts.subheadline)
                .foregroundColor(ThemeColors.gray)
        }
        .padding(ThemeSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                .fill(ThemeColors.warning.opacity(0.1))
        )
        .padding(.horizontal, ThemeSpacing.md)
    }
    
    private var participantsSection: some View {
        VStack(spacing: ThemeSpacing.md) {
            HStack {
                Text("Participants")
                    .font(ThemeFonts.title2)
                    .foregroundColor(ThemeColors.primary)
                
                Spacer()
                
                if contribution.status != .allPaid {
                    Button("Mark partial for all") {
                        showBulkPaymentSheet = true
                    }
                    .font(ThemeFonts.caption1)
                    .foregroundColor(ThemeColors.primary)
                }
            }
            .padding(.horizontal, ThemeSpacing.md)
            
            LazyVStack(spacing: ThemeSpacing.sm) {
                ForEach(contribution.participants) { participant in
                    ParticipantRowView(
                        participant: participant,
                        requiredAmount: contribution.perPersonAmount
                    ) {
                        selectedParticipant = participant
                    }
                }
            }
            .padding(.horizontal, ThemeSpacing.md)
        }
    }
}
