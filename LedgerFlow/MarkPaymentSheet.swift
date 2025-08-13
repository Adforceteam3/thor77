import SwiftUI

struct MarkPaymentSheet: View {
    let contribution: ContributionModel
    let participant: ParticipantModel
    @EnvironmentObject var appStore: AppStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var amountText = ""
    @State private var isFullPayment = false
    @State private var amountError: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedBackground()
                
                ScrollView {
                    VStack(spacing: ThemeSpacing.lg) {
                        participantInfo
                        
                        paymentForm
                        
                        PrimaryButtonView(
                            title: "Record Payment",
                            action: recordPayment,
                            isEnabled: isFormValid
                        )
                        
                        Spacer(minLength: 100)
                    }
                    .padding(ThemeSpacing.lg)
                }
                .hideKeyboardOnTap()
            }
            .navigationTitle("Mark Payment")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ThemeColors.primary)
                }
            }
        }
        .onAppear {
            updateFullPaymentAmount()
        }
        .onChange(of: isFullPayment) { _ in
            updateFullPaymentAmount()
        }
        .onChange(of: amountText) { _ in
            validateAmount()
        }
    }
    
    private var participantInfo: some View {
        VStack(spacing: ThemeSpacing.md) {
            Text(participant.name)
                .font(ThemeFonts.title2)
                .foregroundColor(ThemeColors.primary)
            
            VStack(spacing: ThemeSpacing.sm) {
                HStack {
                    Text("Required amount:")
                        .font(ThemeFonts.body)
                        .foregroundColor(ThemeColors.gray)
                    Spacer()
                    Text(contribution.perPersonAmount.currencyFormatted)
                        .font(ThemeFonts.body)
                        .foregroundColor(ThemeColors.primary)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Already paid:")
                        .font(ThemeFonts.body)
                        .foregroundColor(ThemeColors.gray)
                    Spacer()
                    Text(participant.totalPaid.currencyFormatted)
                        .font(ThemeFonts.body)
                        .foregroundColor(ThemeColors.success)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Remaining:")
                        .font(ThemeFonts.body)
                        .foregroundColor(ThemeColors.gray)
                    Spacer()
                    Text(remainingAmount.currencyFormatted)
                        .font(ThemeFonts.body)
                        .foregroundColor(ThemeColors.warning)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(ThemeSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                .fill(ThemeColors.white)
                .shadow(color: ThemeColors.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var paymentForm: some View {
        VStack(spacing: ThemeSpacing.md) {
            Toggle("Full payment", isOn: $isFullPayment)
                .font(ThemeFonts.headline)
                .foregroundColor(ThemeColors.primary)
            
            VStack(alignment: .leading, spacing: ThemeSpacing.sm) {
                TextField("Payment amount", text: $amountText)
                    .font(ThemeFonts.body)
                    .keyboardType(.decimalPad)
                    .disabled(isFullPayment)
                    .padding(ThemeSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                            .fill(isFullPayment ? ThemeColors.lightGray : ThemeColors.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                            .stroke(amountError != nil ? ThemeColors.danger : Color.clear, lineWidth: 1)
                    )
                
                if let error = amountError {
                    Text(error)
                        .font(ThemeFonts.caption1)
                        .foregroundColor(ThemeColors.danger)
                }
                
                if enteredAmount > remainingAmount && !amountText.isEmpty {
                    Text("Amount exceeds remaining balance. Will be capped at \(remainingAmount.currencyFormatted)")
                        .font(ThemeFonts.caption1)
                        .foregroundColor(ThemeColors.warning)
                }
            }
        }
        .padding(ThemeSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                .fill(ThemeColors.white)
                .shadow(color: ThemeColors.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var remainingAmount: Double {
        max(0, contribution.perPersonAmount - participant.totalPaid)
    }
    
    private var enteredAmount: Double {
        Double(amountText) ?? 0
    }
    
    private var actualPaymentAmount: Double {
        min(enteredAmount, remainingAmount)
    }
    
    private var isFormValid: Bool {
        amountError == nil && !amountText.isEmpty && enteredAmount > 0
    }
    
    private func updateFullPaymentAmount() {
        if isFullPayment {
            let formatted = remainingAmount.currencyFormattedNoSymbol
            let sanitized = formatted.replacingOccurrences(of: ",", with: ".")
            amountText = sanitized
            amountError = nil
        }
    }
    
    private func validateAmount() {
        let validation = ValidationHelpers.validateAmount(amountText)
        amountError = validation.isValid ? nil : validation.message
    }
    
    private func recordPayment() {
        validateAmount()
        guard isFormValid else { return }
        
        let payment = PaymentModel(
            contributionId: contribution.id,
            participantId: participant.id,
            amount: actualPaymentAmount
        )
        
        appStore.addPayment(payment)
        HapticsService.shared.success()
        dismiss()
    }
}

struct BulkPaymentSheet: View {
    let contribution: ContributionModel
    @EnvironmentObject var appStore: AppStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var amountText = ""
    @State private var amountError: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedBackground()
                
                ScrollView {
                    VStack(spacing: ThemeSpacing.lg) {
                        VStack(alignment: .leading, spacing: ThemeSpacing.md) {
                            Text("Apply partial payment to all participants who haven't fully paid")
                                .font(ThemeFonts.body)
                                .foregroundColor(ThemeColors.gray)
                                .multilineTextAlignment(.leading)
                            
                            Text("This will add the specified amount to each participant's balance, up to their required amount.")
                                .font(ThemeFonts.caption1)
                                .foregroundColor(ThemeColors.gray)
                                .multilineTextAlignment(.leading)
                        }
                        
                        VStack(alignment: .leading, spacing: ThemeSpacing.sm) {
                            TextField("Amount to add per person", text: $amountText)
                                .font(ThemeFonts.body)
                                .keyboardType(.decimalPad)
                                .padding(ThemeSpacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                                        .fill(ThemeColors.white)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                                        .stroke(amountError != nil ? ThemeColors.danger : Color.clear, lineWidth: 1)
                                )
                            
                            if let error = amountError {
                                Text(error)
                                    .font(ThemeFonts.caption1)
                                    .foregroundColor(ThemeColors.danger)
                            }
                        }
                        
                        PrimaryButtonView(
                            title: "Apply to All",
                            action: applyBulkPayment,
                            isEnabled: isFormValid
                        )
                        
                        Spacer(minLength: 100)
                    }
                    .padding(ThemeSpacing.lg)
                }
            }
            .navigationTitle("Bulk Payment")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ThemeColors.primary)
                }
            }
        }
        .onChange(of: amountText) { _ in
            validateAmount()
        }
    }
    
    private var isFormValid: Bool {
        amountError == nil && !amountText.isEmpty && (Double(amountText) ?? 0) > 0
    }
    
    private func validateAmount() {
        let validation = ValidationHelpers.validateAmount(amountText)
        amountError = validation.isValid ? nil : validation.message
    }
    
    private func applyBulkPayment() {
        validateAmount()
        guard isFormValid else { return }
        
        let amount = Double(amountText) ?? 0
        
        for participant in contribution.participants {
            let remainingAmount = max(0, contribution.perPersonAmount - participant.totalPaid)
            if remainingAmount > 0 {
                let paymentAmount = min(amount, remainingAmount)
                let payment = PaymentModel(
                    contributionId: contribution.id,
                    participantId: participant.id,
                    amount: paymentAmount
                )
                appStore.addPayment(payment)
            }
        }
        
        HapticsService.shared.success()
        dismiss()
    }
}
