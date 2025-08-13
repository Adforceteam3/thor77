import Foundation

struct AnalyticsSnapshot: Codable {
    let date: Date
    let totalCollected: Double
    let activeContributions: Int
    let paymentsCount: Int
    let topGroupName: String?
    let topGroupAmount: Double
    
    init(date: Date, totalCollected: Double, activeContributions: Int, paymentsCount: Int, topGroupName: String? = nil, topGroupAmount: Double = 0) {
        self.date = date
        self.totalCollected = totalCollected
        self.activeContributions = activeContributions
        self.paymentsCount = paymentsCount
        self.topGroupName = topGroupName
        self.topGroupAmount = topGroupAmount
    }
}

struct CandlestickPoint: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Int
    
    var isPositive: Bool {
        close >= open
    }
}
