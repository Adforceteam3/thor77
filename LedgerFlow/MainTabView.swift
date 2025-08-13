import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appStore: AppStore
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $appStore.selectedTab) {
                HomeScreenView()
                    .tag(AppTab.home)
                
                AnalyticsScreenView()
                    .tag(AppTab.analytics)
                
                HistoryScreenView()
                    .tag(AppTab.history)
                
                ParticipantsStatsScreenView()
                    .tag(AppTab.participants)
                
                SettingsScreenView()
                    .tag(AppTab.settings)
            }
            
            VStack {
                Spacer()
                CustomTabBarView(selectedTab: $appStore.selectedTab)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}
