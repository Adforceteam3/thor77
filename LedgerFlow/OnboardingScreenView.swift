import SwiftUI

struct OnboardingScreenView: View {
    @EnvironmentObject var appStore: AppStore
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    
    private let pages = OnboardingPage.allPages
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page, pageIndex: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .offset(x: dragOffset)
                
                VStack(spacing: ThemeSpacing.lg) {
                    HStack(spacing: ThemeSpacing.sm) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? ThemeColors.primary : ThemeColors.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                    
                    if currentPage < pages.count - 1 {
                        PrimaryButtonView(
                            title: "Continue",
                            action: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentPage += 1
                                }
                                HapticsService.shared.light()
                            }
                        )
                        .padding(.horizontal, ThemeSpacing.lg)
                    } else {
                        PrimaryButtonView(
                            title: "Get Started",
                            action: {
                                HapticsService.shared.success()
                                appStore.completeOnboarding()
                            }
                        )
                        .padding(.horizontal, ThemeSpacing.lg)
                    }
                }
                .padding(.bottom, ThemeSpacing.xxl)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    let threshold: CGFloat = 50
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if value.translation.width > threshold && currentPage > 0 {
                            currentPage -= 1
                        } else if value.translation.width < -threshold && currentPage < pages.count - 1 {
                            currentPage += 1
                        }
                        dragOffset = 0
                    }
                }
        )
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int
    @State private var imageOffset: CGFloat = 100
    @State private var textOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: ThemeSpacing.xxl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(ThemeColors.primary.opacity(0.1))
                    .frame(width: 280, height: 280)
                    .offset(y: imageOffset * 0.3)
                
                Circle()
                    .fill(ThemeColors.accent.opacity(0.05))
                    .frame(width: 200, height: 200)
                    .offset(y: imageOffset * 0.5)
                
                Image(systemName: page.iconName)
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(ThemeColors.primary)
                    .offset(y: imageOffset)
            }
            
            VStack(spacing: ThemeSpacing.lg) {
                Text(page.title)
                    .font(ThemeFonts.largeTitle)
                    .foregroundColor(ThemeColors.primary)
                    .multilineTextAlignment(.center)
                    .opacity(textOpacity)
                
                Text(page.description)
                    .font(ThemeFonts.body)
                    .foregroundColor(ThemeColors.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .opacity(textOpacity)
            }
            .padding(.horizontal, ThemeSpacing.lg)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(Double(pageIndex) * 0.1)) {
                imageOffset = 0
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.3 + Double(pageIndex) * 0.1)) {
                textOpacity = 1
            }
        }
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let description: String
    
    static let allPages = [
        OnboardingPage(
            iconName: "person.3.sequence.fill",
            title: "Track Contributions with Ease",
            description: "Organize group contributions effortlessly. Keep track of who has paid and who hasn't in your team or group activities."
        ),
        OnboardingPage(
            iconName: "chart.bar.doc.horizontal.fill",
            title: "Detailed Analytics",
            description: "Get insights into payment patterns with beautiful charts and comprehensive statistics to understand your group's financial dynamics."
        ),
        OnboardingPage(
            iconName: "checkmark.seal.fill",
            title: "Stay Organized",
            description: "Never lose track of payments again. Set due dates, monitor progress, and ensure everyone contributes their fair share."
        )
    ]
}
