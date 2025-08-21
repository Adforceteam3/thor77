import SwiftUI
import StoreKit

struct SettingsScreenView: View {
    @EnvironmentObject var appStore: AppStore
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        TabContentContainerView {
            VStack(spacing: ThemeSpacing.lg) {
                SectionHeaderView("Settings", subtitle: "App preferences and information")
                
                VStack(spacing: ThemeSpacing.md) {
                    settingsItems
                }
                
                Spacer(minLength: 100)
            }
        }
    }
    
    private var settingsItems: some View {
        VStack(spacing: ThemeSpacing.sm) {
            SettingsRow(
                icon: "doc.text.fill",
                title: "Terms and Conditions",
                subtitle: "Review our terms of service",
                action: {
                    viewModel.openURL("https://sites.google.com/adforcegroup.com/id-6751351335")
                }
            )
            
            SettingsRow(
                icon: "lock.shield.fill",
                title: "Privacy Policy",
                subtitle: "How we protect your data",
                action: {
                    viewModel.openURL("https://sites.google.com/adforcegroup.com/id6751351335")
                }
            )
            
            SettingsRow(
                icon: "envelope.fill",
                title: "Contact Us",
                subtitle: "Get help and support",
                action: {
                    viewModel.openURL("https://forms.gle/JdLau6UAtPjbv5Wc7")
                }
            )
            
            SettingsRow(
                icon: "star.fill",
                title: "Rate App",
                subtitle: "Help us improve with your feedback",
                action: {
                    viewModel.requestReview()
                }
            )
        }
        .padding(.horizontal, ThemeSpacing.md)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: (() -> Void)?
    
    var body: some View {
        Button {
            action?()
            HapticsService.shared.light()
        } label: {
            HStack(spacing: ThemeSpacing.md) {
                Image(systemName: icon)
                    .font(ThemeFonts.title3)
                    .foregroundColor(ThemeColors.primary)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: ThemeSpacing.xs) {
                    Text(title)
                        .font(ThemeFonts.headline)
                        .foregroundColor(ThemeColors.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(subtitle)
                        .font(ThemeFonts.caption1)
                        .foregroundColor(ThemeColors.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(ThemeFonts.caption1)
                        .foregroundColor(ThemeColors.gray)
                }
            }
            .padding(ThemeSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                    .fill(ThemeColors.white)
                    .shadow(color: ThemeColors.black.opacity(0.02), radius: 4, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

struct SectionDivider: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(ThemeFonts.caption1)
                .foregroundColor(ThemeColors.gray)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .padding(.horizontal, ThemeSpacing.md)
        .padding(.top, ThemeSpacing.lg)
    }
}
