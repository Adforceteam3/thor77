import SwiftUI

struct ResponsibleTopListView: View {
    let participants: [ResponsibleParticipant]
    
    var body: some View {
        VStack(spacing: ThemeSpacing.sm) {
            if participants.isEmpty {
                Text("No data available")
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
                    ResponsibleParticipantRow(
                        participant: participant,
                        rank: index + 1
                    )
                }
                .padding(.horizontal, ThemeSpacing.md)
            }
        }
    }
}

struct ResponsibleParticipantRow: View {
    let participant: ResponsibleParticipant
    let rank: Int
    
    var body: some View {
        HStack(spacing: ThemeSpacing.md) {
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 32, height: 32)
                
                Text("\(rank)")
                    .font(ThemeFonts.caption1)
                    .foregroundColor(ThemeColors.white)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: ThemeSpacing.xs) {
                Text(participant.name)
                    .font(ThemeFonts.headline)
                    .foregroundColor(ThemeColors.primary)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("On-time: \(Int(participant.onTimePercentage))%")
                            .font(ThemeFonts.caption1)
                            .foregroundColor(onTimeColor)
                        
                        Text("Avg: \(participant.averageContribution.currencyFormatted)")
                            .font(ThemeFonts.caption1)
                            .foregroundColor(ThemeColors.gray)
                    }
                    
                    Spacer()
                    
                    Text(participant.totalGiven.currencyFormatted)
                        .font(ThemeFonts.subheadline)
                        .foregroundColor(ThemeColors.success)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(ThemeSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                .fill(ThemeColors.white)
                .shadow(color: ThemeColors.black.opacity(0.02), radius: 4, x: 0, y: 1)
        )
    }
    
    private var rankColor: Color {
        switch rank {
        case 1:
            return ThemeColors.warning
        case 2:
            return ThemeColors.gray
        case 3:
            return Color.brown
        default:
            return ThemeColors.primary
        }
    }
    
    private var onTimeColor: Color {
        if participant.onTimePercentage >= 90 {
            return ThemeColors.success
        } else if participant.onTimePercentage >= 70 {
            return ThemeColors.warning
        } else {
            return ThemeColors.danger
        }
    }
}
