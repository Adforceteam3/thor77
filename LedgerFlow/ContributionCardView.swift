import SwiftUI

struct ContributionCardView: View {
    let contribution: ContributionModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: ThemeSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: ThemeSpacing.xs) {
                    Text(contribution.groupName)
                        .font(ThemeFonts.headline)
                        .foregroundColor(ThemeColors.primary)
                    
                    Text("\(contribution.perPersonAmount.currencyFormatted) per participant")
                        .font(ThemeFonts.caption1)
                        .foregroundColor(ThemeColors.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: ThemeSpacing.xs) {
                    StatusIndicator(status: contribution.status, isOverdue: contribution.isOverdue)
                    
                    if let dueDate = contribution.dueDate {
                        Text(DateFormatter.shortDate.string(from: dueDate))
                            .font(ThemeFonts.caption2)
                            .foregroundColor(contribution.isOverdue ? ThemeColors.danger : ThemeColors.gray)
                    }
                }
            }
            
            HStack {
                Text("Progress")
                    .font(ThemeFonts.caption1)
                    .foregroundColor(ThemeColors.gray)
                
                Spacer()
                
                Text("\(contribution.paidParticipantsCount)/\(contribution.participants.count) paid")
                    .font(ThemeFonts.caption1)
                    .foregroundColor(ThemeColors.primary)
            }
            
            ProgressView(value: Double(contribution.paidParticipantsCount), total: Double(contribution.participants.count))
                .progressViewStyle(LinearProgressViewStyle(tint: contribution.status.progressColor))
            
            HStack {
                VStack(alignment: .leading, spacing: ThemeSpacing.xs) {
                    Text("Collected")
                        .font(ThemeFonts.caption2)
                        .foregroundColor(ThemeColors.gray)
                    Text(contribution.totalCollected.currencyFormatted)
                        .font(ThemeFonts.callout)
                        .foregroundColor(ThemeColors.primary)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: ThemeSpacing.xs) {
                    Text("Needed")
                        .font(ThemeFonts.caption2)
                        .foregroundColor(ThemeColors.gray)
                    Text(contribution.totalNeeded.currencyFormatted)
                        .font(ThemeFonts.callout)
                        .foregroundColor(ThemeColors.primary)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(ThemeSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                .fill(ThemeColors.white)
                .shadow(color: ThemeColors.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .scaleEffect(0.98)
        .animation(.easeInOut(duration: 0.2), value: contribution.id)
    }
}

struct StatusIndicator: View {
    let status: ContributionStatus
    let isOverdue: Bool
    
    var body: some View {
        HStack(spacing: ThemeSpacing.xs) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(isOverdue ? "Overdue" : status.rawValue)
                .font(ThemeFonts.caption1)
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
        if isOverdue {
            return ThemeColors.danger
        }
        
        switch status {
        case .allPaid:
            return ThemeColors.success
        case .partial:
            return ThemeColors.warning
        case .none:
            return ThemeColors.danger
        case .all:
            return ThemeColors.gray
        }
    }
}

extension ContributionStatus {
    var progressColor: Color {
        switch self {
        case .allPaid:
            return ThemeColors.success
        case .partial:
            return ThemeColors.warning
        case .none:
            return ThemeColors.danger
        case .all:
            return ThemeColors.gray
        }
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}
