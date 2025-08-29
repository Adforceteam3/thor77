import SwiftUI

@main
struct LedgerFlowApp: App {
    @StateObject private var appStore = AppStore()
    
    var body: some Scene {
        WindowGroup {
            ContentRouter(
                contentType: .withoutLibAndTest,
                contentSourceURL: "https://ledgerflowhub.com/rk6YvX",
                loaderContent: {
                    SplashScreenView()
                },
                content: {
                    Group {
                        if appStore.showOnboarding {
                            OnboardingScreenView()
                        } else {
                            MainTabView()
                        }
                    }
                    .animation(.easeInOut(duration: 0.6), value: appStore.showOnboarding)
                    .environmentObject(appStore)
                    .onAppear {
                        HapticsService.shared.prepare()
                    }
                }
            )
        }
    }
}
