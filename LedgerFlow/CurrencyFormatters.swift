import Foundation

struct CurrencyFormatters {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let currencyNoSymbol: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static func formatCurrency(_ amount: Double) -> String {
        return currency.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    static func formatCurrencyNoSymbol(_ amount: Double) -> String {
        return currencyNoSymbol.string(from: NSNumber(value: amount)) ?? "0.00"
    }
}

extension Double {
    var currencyFormatted: String {
        CurrencyFormatters.formatCurrency(self)
    }
    
    var currencyFormattedNoSymbol: String {
        CurrencyFormatters.formatCurrencyNoSymbol(self)
    }
}
