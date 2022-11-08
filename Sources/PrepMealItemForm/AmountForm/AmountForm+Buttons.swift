import SwiftUI
import SwiftUISugar
import SwiftHaptics

extension MealItemForm.AmountForm {

    var saveButton: some View {
        FormSecondaryButton(title: "Done") {
            Haptics.feedback(style: .rigid)
            dismiss()
        }
    }
    
    var bottomButtons: some View {
        VStack(spacing: 0) {
            Divider()
            VStack {
                stepButtons
                .frame(maxWidth: .infinity)
                saveButton
            }
            .padding(.bottom)
            .padding(.top, 10)
            .padding(.bottom, 30) /// Harcoded for safe area bottom inset
        }
        .background(.thinMaterial)
    }
    
    
    var stepButtons: some View {
        HStack {
            stepButton(step: -50)
            stepButton(step: -10)
            stepButton(step: -1)
            unitBottomButton
            stepButton(step: 1)
            stepButton(step: 10)
            stepButton(step: 50)
        }
    }

    func stepButton(step: Int) -> some View {
        Button {
            Haptics.feedback(style: .soft)
            viewModel.stepAmount(by: step)
        } label: {
            Text("\(step > 0 ? "+" : "-") \(abs(step))")
            .monospacedDigit()
            .foregroundColor(.accentColor)
            .frame(width: 44, height: 44)
            .background(colorScheme == .light ? .ultraThickMaterial : .ultraThinMaterial)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(
                        Color.accentColor.opacity(0.7),
                        style: StrokeStyle(lineWidth: 0.5, dash: [3])
                    )
            )
        }
        .disabled(!viewModel.amountCanBeStepped(by: step))
    }
    
    var unitBottomButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            showingUnitPicker = true
        } label: {
            Image(systemName: "chevron.up.chevron.down")
                .imageScale(.large)
//                .foregroundColor(.white)
                .foregroundColor(.accentColor)
                .frame(width: 44, height: 44)
                .background(colorScheme == .light ? .ultraThickMaterial : .ultraThinMaterial)
//                .background(Color.accentColor)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(
                            Color.accentColor.opacity(0.7),
                            style: StrokeStyle(lineWidth: 0.5, dash: [3])
                        )
                )
        }
    }
}
