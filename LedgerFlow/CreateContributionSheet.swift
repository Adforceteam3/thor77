import SwiftUI

struct CreateContributionSheet: View {
    @EnvironmentObject var appStore: AppStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var groupName = ""
    @State private var perPersonAmountText = ""
    @State private var participantNames: [String] = [""]
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    
    @State private var groupNameError: String?
    @State private var amountError: String?
    @State private var participantsError: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedBackground()
                
                ScrollView {
                    VStack(spacing: ThemeSpacing.lg) {
                        VStack(alignment: .leading, spacing: ThemeSpacing.md) {
                            Text("Group Details")
                                .font(ThemeFonts.headline)
                                .foregroundColor(ThemeColors.primary)
                            
                            VStack(alignment: .leading, spacing: ThemeSpacing.sm) {
                                TextField("Group name", text: $groupName)
                                    .font(ThemeFonts.body)
                                    .padding(ThemeSpacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                                            .fill(ThemeColors.white)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                                            .stroke(groupNameError != nil ? ThemeColors.danger : Color.clear, lineWidth: 1)
                                    )
                                
                                if let error = groupNameError {
                                    Text(error)
                                        .font(ThemeFonts.caption1)
                                        .foregroundColor(ThemeColors.danger)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: ThemeSpacing.sm) {
                                TextField("Amount per person", text: $perPersonAmountText)
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
                        }
                        
                        VStack(alignment: .leading, spacing: ThemeSpacing.md) {
                            HStack {
                                Text("Participants")
                                    .font(ThemeFonts.headline)
                                    .foregroundColor(ThemeColors.primary)
                                
                                Spacer()
                                
                                Button {
                                    participantNames.append("")
                                    HapticsService.shared.light()
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(ThemeFonts.title3)
                                        .foregroundColor(ThemeColors.primary)
                                }
                            }
                            
                            ForEach(Array(participantNames.enumerated()), id: \.offset) { index, name in
                                HStack {
                                    TextField("Participant \(index + 1) name", text: $participantNames[index])
                                        .font(ThemeFonts.body)
                                        .padding(ThemeSpacing.md)
                                        .background(
                                            RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                                                .fill(ThemeColors.white)
                                        )
                                    
                                    if participantNames.count > 1 {
                                        Button {
                                            participantNames.remove(at: index)
                                            HapticsService.shared.light()
                                        } label: {
                                            Image(systemName: "minus.circle.fill")
                                                .font(ThemeFonts.body)
                                                .foregroundColor(ThemeColors.danger)
                                        }
                                    }
                                }
                            }
                            
                            if let error = participantsError {
                                Text(error)
                                    .font(ThemeFonts.caption1)
                                    .foregroundColor(ThemeColors.danger)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: ThemeSpacing.md) {
                            Toggle("Set due date", isOn: $hasDueDate)
                                .font(ThemeFonts.headline)
                                .foregroundColor(ThemeColors.primary)
                            
                            if hasDueDate {
                                DatePicker("Due date", selection: $dueDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .padding(ThemeSpacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: ThemeCornerRadius.medium)
                                            .fill(ThemeColors.white)
                                    )
                            }
                        }
                        
                        PrimaryButtonView(
                            title: "Create Contribution",
                            action: createContribution,
                            isEnabled: isFormValid
                        )
                        
                        Spacer(minLength: 100)
                    }
                    .padding(ThemeSpacing.lg)
                }
                .hideKeyboardOnTap()
            }
            .navigationTitle("New Contribution")
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
        .onChange(of: groupName) { _ in validateGroupName() }
        .onChange(of: perPersonAmountText) { _ in validateAmount() }
        .onChange(of: participantNames) { _ in validateParticipants() }
    }
    
    private var isFormValid: Bool {
        groupNameError == nil && amountError == nil && participantsError == nil &&
        !groupName.isEmpty && !perPersonAmountText.isEmpty &&
        participantNames.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count >= 1
    }
    
    private func validateGroupName() {
        let validation = ValidationHelpers.validateGroupName(groupName)
        groupNameError = validation.isValid ? nil : validation.message
    }
    
    private func validateAmount() {
        let validation = ValidationHelpers.validateAmount(perPersonAmountText)
        amountError = validation.isValid ? nil : validation.message
    }
    
    private func validateParticipants() {
        let validNames = participantNames.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        if validNames.isEmpty {
            participantsError = "At least one participant is required"
        } else if Set(validNames).count != validNames.count {
            participantsError = "Participant names must be unique"
        } else {
            participantsError = nil
        }
    }
    
    private func createContribution() {
        validateGroupName()
        validateAmount()
        validateParticipants()
        
        guard isFormValid else { return }
        
        let amountValidation = ValidationHelpers.validateAmount(perPersonAmountText)
        guard amountValidation.isValid else { return }
        
        let validParticipantNames = participantNames.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let participants = validParticipantNames.map { ParticipantModel(name: $0.trimmingCharacters(in: .whitespacesAndNewlines)) }
        
        let contribution = ContributionModel(
            groupName: groupName.trimmingCharacters(in: .whitespacesAndNewlines),
            perPersonAmount: amountValidation.value,
            participants: participants,
            dueDate: hasDueDate ? dueDate : nil
        )
        
        appStore.createContribution(contribution)
        HapticsService.shared.success()
        dismiss()
    }
}
