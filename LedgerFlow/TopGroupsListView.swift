import SwiftUI

struct TopGroupsListView: View {
    let groups: [GroupAnalytics]
    
    var body: some View {
        VStack(spacing: ThemeSpacing.sm) {
            if groups.isEmpty {
                Text("No group data available")
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
                ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
                    GroupAnalyticsRow(
                        group: group,
                        rank: index + 1,
                        maxAmount: groups.first?.amount ?? 1
                    )
                }
                .padding(.horizontal, ThemeSpacing.md)
            }
        }
    }
}

struct GroupAnalyticsRow: View {
    let group: GroupAnalytics
    let rank: Int
    let maxAmount: Double
    
    var body: some View {
        HStack(spacing: ThemeSpacing.md) {
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 24, height: 24)
                
                Text("\(rank)")
                    .font(ThemeFonts.caption1)
                    .foregroundColor(ThemeColors.white)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: ThemeSpacing.xs) {
                Text(group.name)
                    .font(ThemeFonts.headline)
                    .foregroundColor(ThemeColors.primary)
                
                HStack {
                    Text(group.amount.currencyFormatted)
                        .font(ThemeFonts.subheadline)
                        .foregroundColor(ThemeColors.success)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(Int(group.percentage))%")
                        .font(ThemeFonts.caption1)
                        .foregroundColor(ThemeColors.gray)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(ThemeColors.lightGray)
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(rankColor)
                            .frame(width: geometry.size.width * (group.amount / maxAmount), height: 4)
                    }
                }
                .frame(height: 4)
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
}
