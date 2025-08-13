import SwiftUI

struct ParticipantRowView: View {
    let participant: ParticipantModel
    let requiredAmount: Double
    let onMarkPayment: () -> Void
    
    var body: some View {
        HStack(spacing: ThemeSpacing.md) {
            VStack(alignment: .leading, spacing: ThemeSpacing.xs) {
                Text(participant.name)
                    .font(ThemeFonts.headline)
                    .foregroundColor(ThemeColors.primary)
                
                Text("Paid so far: \(participant.totalPaid.currencyFormatted) / \(requiredAmount.currencyFormatted)")
                    .font(ThemeFonts.caption1)
                    .foregroundColor(ThemeColors.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: ThemeSpacing.xs) {
                ParticipantStatusChip(
                    status: participant.paymentStatus(requiredAmount: requiredAmount)
                )
                
                Button("Mark payment") {
                    onMarkPayment()
                    HapticsService.shared.light()
                }
                .font(ThemeFonts.caption1)
                .foregroundColor(ThemeColors.primary)
                .padding(.horizontal, ThemeSpacing.sm)
                .padding(.vertical, ThemeSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: ThemeCornerRadius.small)
                        .fill(ThemeColors.primary.opacity(0.1))
                )
            }
        }
        .padding(ThemeSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                .fill(ThemeColors.white)
                .shadow(color: ThemeColors.black.opacity(0.02), radius: 4, x: 0, y: 1)
        )
    }
}

struct ParticipantStatusChip: View {
    let status: ParticipantPaymentStatus
    
    var body: some View {
        HStack(spacing: ThemeSpacing.xs) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            
            Text(status.rawValue)
                .font(ThemeFonts.caption2)
                .foregroundColor(statusColor)
                .fontWeight(.medium)
        }
        .padding(.horizontal, ThemeSpacing.sm)
        .padding(.vertical, ThemeSpacing.xs)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.small)
                .fill(statusColor.opacity(0.1))
        )
    }
    
    private var statusColor: Color {
        switch status {
        case .paid:
            return ThemeColors.success
        case .partial:
            return ThemeColors.warning
        case .notPaid:
            return ThemeColors.danger
        }
    }
}
