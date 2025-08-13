import Foundation

struct AppState: Codable {
    var contributions: [ContributionModel] = []
    var payments: [PaymentModel] = []
    var hasCompletedOnboarding: Bool = false
    var selectedTabIndex: Int = 0
    
    init() {}
}

enum AppTab: Int, CaseIterable {
    case home = 0
    case analytics = 1
    case history = 2
    case participants = 3
    case settings = 4
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .analytics: return "Analytics"
        case .history: return "History"
        case .participants: return "Participants"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .analytics: return "chart.bar.fill"
        case .history: return "clock.fill"
        case .participants: return "person.3.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
