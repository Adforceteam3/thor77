import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let buttonTitle: String?
    let buttonAction: (() -> Void)?
    
    init(icon: String, title: String, subtitle: String, buttonTitle: String? = nil, buttonAction: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        VStack(spacing: ThemeSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(ThemeColors.gray)
            
            VStack(spacing: ThemeSpacing.sm) {
                Text(title)
                    .font(ThemeFonts.title3)
                    .foregroundColor(ThemeColors.primary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(ThemeFonts.body)
                    .foregroundColor(ThemeColors.gray)
                    .multilineTextAlignment(.center)
            }
            
            if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
                PrimaryButtonView(
                    title: buttonTitle,
                    action: buttonAction
                )
                .padding(.top, ThemeSpacing.md)
            }
        }
        .padding(ThemeSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
