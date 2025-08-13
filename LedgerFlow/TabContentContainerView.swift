import SwiftUI

struct TabContentContainerView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            ScrollView {
                VStack {
                    content
                }
                .padding(.top, 30)
                .padding(.bottom, 80)
                .padding(.horizontal, ThemeSpacing.md)
            }
            .hideKeyboardOnTap()
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}
