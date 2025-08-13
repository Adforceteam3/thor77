import SwiftUI

struct TotalContributionBarsView: View {
    let participants: [ContributionParticipant]
    
    var body: some View {
        VStack(spacing: ThemeSpacing.sm) {
            if participants.isEmpty {
                Text("No contribution data available")
                    .font(ThemeFonts.body)
                    .foregroundColor(ThemeColors.gray)
                    .frame(maxWidth: .infinity)
                    .padding(ThemeSpacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                            .fill(ThemeColors.lightGray)
                    )
                    .padding(.horizontal, ThemeSpacing.md)
            } else {
                ForEach(Array(participants.enumerated()), id: \.element.id) { index, participant in
                    ContributionBarRow(
                        participant: participant,
                        rank: index + 1,
                        maxAmount: participants.first?.totalAmount ?? 1
                    )
                }
                .padding(.horizontal, ThemeSpacing.md)
            }
        }
    }
}

struct ContributionBarRow: View {
    let participant: ContributionParticipant
    let rank: Int
    let maxAmount: Double
    
    var body: some View {
        VStack(spacing: ThemeSpacing.sm) {
            HStack {
                HStack(spacing: ThemeSpacing.sm) {
                    Text("\(rank).")
                        .font(ThemeFonts.caption1)
                        .foregroundColor(ThemeColors.gray)
                        .fontWeight(.bold)
                        .frame(width: 20, alignment: .trailing)
                    
                    Text(participant.name)
                        .font(ThemeFonts.subheadline)
                        .foregroundColor(ThemeColors.primary)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Text(participant.totalAmount.currencyFormatted)
                    .font(ThemeFonts.subheadline)
                    .foregroundColor(ThemeColors.success)
                    .fontWeight(.semibold)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ThemeColors.lightGray)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(
                            width: geometry.size.width * (participant.totalAmount / maxAmount),
                            height: 8
                        )
                        .animation(.easeInOut(duration: 0.6), value: participant.totalAmount)
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, ThemeSpacing.sm)
        .padding(.horizontal, ThemeSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                .fill(ThemeColors.white)
                .shadow(color: ThemeColors.black.opacity(0.02), radius: 4, x: 0, y: 1)
        )
    }
    
    private var barColor: Color {
        switch rank {
        case 1:
            return ThemeColors.warning
        case 2:
            return ThemeColors.primary
        case 3:
            return ThemeColors.accent
        default:
            return ThemeColors.success
        }
    }
}
