import SwiftUI

struct PaymentRowView: View {
    let payment: PaymentModel
    @EnvironmentObject var appStore: AppStore
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: ThemeSpacing.md) {
                VStack(alignment: .leading, spacing: ThemeSpacing.xs) {
                    HStack {
                        Text(DateFormatter.dateTime.string(from: payment.timestamp))
                            .font(ThemeFonts.caption1)
                            .foregroundColor(ThemeColors.gray)
                        
                        Spacer()
                        
                        Text(payment.amount.currencyFormatted)
                            .font(ThemeFonts.headline)
                            .foregroundColor(ThemeColors.success)
                            .fontWeight(.semibold)
                    }
                    
                    if let participant = findParticipant() {
                        Text(participant.name)
                            .font(ThemeFonts.subheadline)
                            .foregroundColor(ThemeColors.primary)
                            .fontWeight(.medium)
                    }
                    
                    if let contribution = findContribution() {
                        Text("\(contribution.groupName)")
                            .font(ThemeFonts.caption1)
                            .foregroundColor(ThemeColors.gray)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(ThemeFonts.caption1)
                    .foregroundColor(ThemeColors.gray)
            }
            .padding(ThemeSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                    .fill(ThemeColors.white)
                    .shadow(color: ThemeColors.black.opacity(0.02), radius: 4, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func findParticipant() -> ParticipantModel? {
        for contribution in appStore.state.contributions {
            if let participant = contribution.participants.first(where: { $0.id == payment.participantId }) {
                return participant
            }
        }
        return nil
    }
    
    private func findContribution() -> ContributionModel? {
        appStore.state.contributions.first { $0.id == payment.contributionId }
    }
}

extension DateFormatter {
    static let dateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
