import SwiftUI

struct PaymentDetailSheet: View {
    let payment: PaymentModel
    @EnvironmentObject var appStore: AppStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var editMode = false
    @State private var editAmountText = ""
    @State private var amountError: String?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedBackground()
                
                ScrollView {
                    VStack(spacing: ThemeSpacing.lg) {
                        paymentInfo
                        
                        if editMode {
                            editForm
                        } else {
                            actionButtons
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(ThemeSpacing.lg)
                }
                .hideKeyboardOnTap()
            }
            .navigationTitle("Payment Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(ThemeColors.primary)
                }
                
                if editMode {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            editMode = false
                            editAmountText = payment.amount.currencyFormattedNoSymbol
                            amountError = nil
                        }
                        .foregroundColor(ThemeColors.primary)
                    }
                }
            }
        }
        .alert("Delete Payment", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deletePayment()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this payment? This action cannot be undone.")
        }
        .onAppear {
            editAmountText = payment.amount.currencyFormattedNoSymbol
        }
    }
    
    private var paymentInfo: some View {
        VStack(spacing: ThemeSpacing.md) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .font(ThemeFonts.title2)
                    .foregroundColor(ThemeColors.success)
                
                Spacer()
                
                Text(payment.amount.currencyFormatted)
                    .font(ThemeFonts.title1)
                    .foregroundColor(ThemeColors.success)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: ThemeSpacing.sm) {
                InfoRow(label: "Date & Time", value: DateFormatter.dateTime.string(from: payment.timestamp))
                
                if let participant = findParticipant() {
                    InfoRow(label: "Participant", value: participant.name)
                }
                
                if let contribution = findContribution() {
                    InfoRow(label: "Group", value: contribution.groupName)
                    InfoRow(label: "Required per person", value: contribution.perPersonAmount.currencyFormatted)
                }
                
                InfoRow(label: "Payment ID", value: payment.id.uuidString.prefix(8).uppercased())
            }
        }
        .padding(ThemeSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                .fill(ThemeColors.white)
                .shadow(color: ThemeColors.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var editForm: some View {
        VStack(spacing: ThemeSpacing.md) {
            Text("Edit Payment Amount")
                .font(ThemeFonts.headline)
                .foregroundColor(ThemeColors.primary)
            
            VStack(alignment: .leading, spacing: ThemeSpacing.sm) {
                TextField("Amount", text: $editAmountText)
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
            
            HStack(spacing: ThemeSpacing.md) {
                PrimaryButtonView(
                    title: "Save Changes",
                    action: saveChanges,
                    isEnabled: isEditFormValid
                )
                
                PrimaryButtonView(
                    title: "Cancel",
                    action: {
                        editMode = false
                        editAmountText = payment.amount.currencyFormattedNoSymbol
                        amountError = nil
                    },
                    style: .secondary
                )
            }
        }
        .padding(ThemeSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                .fill(ThemeColors.white)
                .shadow(color: ThemeColors.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .onChange(of: editAmountText) { _ in
            validateEditAmount()
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: ThemeSpacing.md) {
            PrimaryButtonView(
                title: "Edit Amount",
                action: {
                    editMode = true
                }
            )
            
            PrimaryButtonView(
                title: "Delete Payment",
                action: {
                    showDeleteConfirmation = true
                },
                style: .destructive
            )
        }
        .padding(ThemeSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                .fill(ThemeColors.white)
                .shadow(color: ThemeColors.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var isEditFormValid: Bool {
        amountError == nil && !editAmountText.isEmpty && (Double(editAmountText) ?? 0) > 0
    }
    
    private func validateEditAmount() {
        let validation = ValidationHelpers.validateAmount(editAmountText)
        amountError = validation.isValid ? nil : validation.message
    }
    
    private func saveChanges() {
        validateEditAmount()
        guard isEditFormValid else { return }
        
        let newAmount = Double(editAmountText) ?? 0
        let oldAmount = payment.amount
        
        var updatedPayment = payment
        updatedPayment.amount = newAmount
        
        appStore.updatePayment(updatedPayment, oldAmount: oldAmount)
        
        editMode = false
        HapticsService.shared.success()
    }
    
    private func deletePayment() {
        appStore.deletePayment(payment.id)
        HapticsService.shared.success()
        dismiss()
    }
    
    private func findParticipant() -> ParticipantModel? {
        for contribution in appStore.state.contributions {
            if let participant = contribution.participants.first(where: { $0.id == payment.participantId }) {
                return participant
            }
        }
        return nil
    }
    
    private func findContribution() -> ContributionModel? {
        appStore.state.contributions.first { $0.id == payment.contributionId }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(ThemeFonts.subheadline)
                .foregroundColor(ThemeColors.gray)
            
            Spacer()
            
            Text(value)
                .font(ThemeFonts.subheadline)
                .foregroundColor(ThemeColors.primary)
                .fontWeight(.medium)
        }
    }
}
