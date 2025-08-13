import SwiftUI

@main
struct LedgerFlowApp: App {
    @StateObject private var appStore = AppStore()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appStore.showSplash {
                    SplashScreenView()
                } else if appStore.showOnboarding {
                    OnboardingScreenView()
                } else {
                    MainTabView()
                }
            }
            .animation(.easeInOut(duration: 0.6), value: appStore.showSplash)
            .animation(.easeInOut(duration: 0.6), value: appStore.showOnboarding)
            .environmentObject(appStore)
            .onAppear {
                HapticsService.shared.prepare()
            }
        }
    }
}
