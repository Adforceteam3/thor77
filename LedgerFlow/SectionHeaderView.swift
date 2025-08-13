import SwiftUI

struct SectionHeaderView: View {
    let title: String
    let subtitle: String?
    
    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: ThemeSpacing.xs) {
            Text(title)
                .font(ThemeFonts.title2)
                .foregroundColor(ThemeColors.primary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(ThemeFonts.subheadline)
                    .foregroundColor(ThemeColors.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, ThemeSpacing.md)
    }
}
