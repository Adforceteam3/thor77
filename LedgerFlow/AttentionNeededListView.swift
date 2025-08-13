import SwiftUI

struct AttentionNeededListView: View {
    let participants: [AttentionParticipant]
    
    var body: some View {
        VStack(spacing: ThemeSpacing.sm) {
            if participants.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(ThemeFonts.title3)
                        .foregroundColor(ThemeColors.success)
                    
                    Text("All participants are up to date!")
                        .font(ThemeFonts.body)
                        .foregroundColor(ThemeColors.success)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                .padding(ThemeSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                        .fill(ThemeColors.success.opacity(0.1))
                )
                .padding(.horizontal, ThemeSpacing.md)
            } else {
                ForEach(participants) { participant in
                    AttentionParticipantRow(participant: participant)
                }
                .padding(.horizontal, ThemeSpacing.md)
            }
        }
    }
}

struct AttentionParticipantRow: View {
    let participant: AttentionParticipant
    
    var body: some View {
        HStack(spacing: ThemeSpacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(ThemeFonts.title3)
                .foregroundColor(severityColor)
            
            VStack(alignment: .leading, spacing: ThemeSpacing.xs) {
                Text(participant.name)
                    .font(ThemeFonts.headline)
                    .foregroundColor(ThemeColors.primary)
                
                HStack {
                    Text("\(participant.overdueCount) overdue")
                        .font(ThemeFonts.caption1)
                        .foregroundColor(ThemeColors.danger)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Total debt:")
                            .font(ThemeFonts.caption2)
                            .foregroundColor(ThemeColors.gray)
                        
                        Text(participant.totalDebt.currencyFormatted)
                            .font(ThemeFonts.subheadline)
                            .foregroundColor(ThemeColors.danger)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding(ThemeSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                .fill(severityColor.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                        .stroke(severityColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var severityColor: Color {
        if participant.totalDebt > 100 {
            return ThemeColors.danger
        } else if participant.totalDebt > 50 {
            return ThemeColors.warning
        } else {
            return ThemeColors.warning
        }
    }
}
