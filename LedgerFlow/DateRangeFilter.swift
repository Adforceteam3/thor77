import Foundation

enum DateRangeFilter: String, CaseIterable {
    case allTime = "All"
    case thisMonth = "This month"
    case lastMonth = "Last month"
    case last7Days = "7 days"
    case last30Days = "30 days"
    case last90Days = "90 days"
    case year = "Year"
    case custom = "Date range"
    
    func dateRange() -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .allTime:
            return nil
        case .thisMonth:
            let start = calendar.dateInterval(of: .month, for: now)?.start ?? now
            return (start, now)
        case .lastMonth:
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            guard let interval = calendar.dateInterval(of: .month, for: lastMonth) else { return nil }
            return (interval.start, interval.end)
        case .last7Days:
            let start = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return (start, now)
        case .last30Days:
            let start = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            return (start, now)
        case .last90Days:
            let start = calendar.date(byAdding: .day, value: -90, to: now) ?? now
            return (start, now)
        case .year:
            let start = calendar.dateInterval(of: .year, for: now)?.start ?? now
            return (start, now)
        case .custom:
            return nil
        }
    }
}

struct CustomDateRange: Equatable {
    var startDate: Date
    var endDate: Date
    
    init(startDate: Date = Date(), endDate: Date = Date()) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    var isValid: Bool {
        startDate <= endDate
    }
}
