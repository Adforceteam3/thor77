import SwiftUI

struct CustomTabBarView: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                TabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                        HapticsService.shared.light()
                    }
                }
            }
        }
        .padding(.horizontal, ThemeSpacing.md)
        .padding(.vertical, ThemeSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.large)
                .fill(ThemeColors.white)
                .shadow(color: ThemeColors.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .padding(.horizontal, ThemeSpacing.md)
        .padding(.bottom, 40)
    }
}

struct TabBarItem: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: ThemeSpacing.xs) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? ThemeColors.primary : ThemeColors.gray)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(tab.title)
                    .font(ThemeFonts.caption2)
                    .foregroundColor(isSelected ? ThemeColors.primary : ThemeColors.gray)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, ThemeSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                    .fill(isSelected ? ThemeColors.primary.opacity(0.1) : Color.clear)
                    .scaleEffect(isSelected ? 1.0 : 0.8)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
