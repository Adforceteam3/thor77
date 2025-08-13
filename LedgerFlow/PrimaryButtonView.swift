import SwiftUI

struct PrimaryButtonView: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var style: ButtonStyle = .primary
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        
        var backgroundColor: Color {
            switch self {
            case .primary: return ThemeColors.primary
            case .secondary: return ThemeColors.lightGray
            case .destructive: return ThemeColors.danger
            }
        }
        
        var textColor: Color {
            switch self {
            case .primary: return ThemeColors.white
            case .secondary: return ThemeColors.primary
            case .destructive: return ThemeColors.white
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(ThemeFonts.headline)
                .foregroundColor(isEnabled ? style.textColor : ThemeColors.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, ThemeSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                        .fill(isEnabled ? style.backgroundColor : ThemeColors.lightGray)
                )
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}
