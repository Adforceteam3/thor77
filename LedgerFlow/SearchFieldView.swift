import SwiftUI

struct SearchFieldView: View {
    @Binding var text: String
    let placeholder: String
    var minCharacters: Int = 2
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ThemeColors.gray)
                .font(ThemeFonts.body)
            
            TextField(placeholder, text: $text)
                .font(ThemeFonts.body)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ThemeColors.gray)
                        .font(ThemeFonts.body)
                }
            }
        }
        .padding(.horizontal, ThemeSpacing.md)
        .padding(.vertical, ThemeSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                .fill(ThemeColors.lightGray)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                .stroke(text.count >= minCharacters ? ThemeColors.primary : Color.clear, lineWidth: 1)
        )
    }
}
