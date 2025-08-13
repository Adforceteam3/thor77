import SwiftUI

struct PillFilterControl<T: Hashable>: View {
    let options: [T]
    @Binding var selection: T
    let displayName: (T) -> String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ThemeSpacing.sm) {
                ForEach(Array(options.enumerated()), id: \.element) { index, option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selection = option
                            HapticsService.shared.light()
                        }
                    } label: {
                        Text(displayName(option))
                            .font(ThemeFonts.footnote)
                            .foregroundColor(selection == option ? ThemeColors.white : ThemeColors.primary)
                            .padding(.horizontal, ThemeSpacing.md)
                            .padding(.vertical, ThemeSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: ThemeCornerRadius.large)
                                    .fill(selection == option ? ThemeColors.primary : ThemeColors.lightGray)
                            )
                    }
                }
            }
            .padding(.horizontal, ThemeSpacing.md)
        }
    }
}
