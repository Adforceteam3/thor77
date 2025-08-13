extension Array where Element == CandlestickPoint {
    func ifEmpty(use placeholder: [CandlestickPoint]) -> [CandlestickPoint] {
        isEmpty ? placeholder : self
    }
}
import Foundation

struct ValidationHelpers {
    static func validateAmount(_ amount: String) -> (isValid: Bool, value: Double, message: String?) {
        guard !amount.isEmpty else {
            return (false, 0, "Amount is required")
        }
        
        let normalized = amount.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Double(normalized) else {
            return (false, 0, "Please enter a valid number")
        }
        
        guard value >= 0.01 else {
            return (false, 0, "Amount must be at least $0.01")
        }
        
        return (true, value, nil)
    }
    
    static func validateGroupName(_ name: String) -> (isValid: Bool, message: String?) {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return (false, "Group name is required")
        }
        
        guard name.count <= 50 else {
            return (false, "Group name must be 50 characters or less")
        }
        
        return (true, nil)
    }
    
    static func validateParticipantName(_ name: String) -> (isValid: Bool, message: String?) {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return (false, "Participant name is required")
        }
        
        guard name.count <= 30 else {
            return (false, "Name must be 30 characters or less")
        }
        
        return (true, nil)
    }
    
    static func validateDateRange(start: Date, end: Date) -> (isValid: Bool, message: String?) {
        guard start <= end else {
            return (false, "Start date must be before or equal to end date")
        }
        
        return (true, nil)
    }
}
