import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar
import PrepViews

extension MealItemForm {
    public struct AmountForm: View {
        
        @EnvironmentObject var viewModel: MealItemForm.ViewModel

        @Environment(\.colorScheme) var colorScheme
        @Environment(\.dismiss) var dismiss
        @Binding var isPresented: Bool
        
        @FocusState var isFocused: Bool
        @State var showingUnitPicker = false
        
        public init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
        }
    }
}

public extension MealItemForm.AmountForm {

    var body: some View {
        ZStack {
            content
            VStack {
                Spacer()
                bottomButtons
            }
            .edgesIgnoringSafeArea(.bottom)
            .transition(.move(edge: .bottom))
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Amount")
        .sheet(isPresented: $showingUnitPicker) { unitPicker }
        .toolbar { trailingCloseButton }
    }
    
    var content: some View {
        FormStyledScrollView {
            textFieldSection
//            equivalentSection
//            nutrientsSummarySection
//            goalIncrementSection
//            mealIncrementSection
        }
    }
    
    var trailingCloseButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                Haptics.feedback(style: .soft)
                isPresented = false
            } label: {
                closeButtonLabel
            }
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
    
    var bottomButtons: some View {
        var saveButton: some View {
            FormSecondaryButton(title: "Done") {
                Haptics.feedback(style: .rigid)
                dismiss()
            }
        }

        return VStack(spacing: 0) {
            Divider()
            VStack {
                HStack {
                    stepButton(step: -50)
                    stepButton(step: -10)
                    stepButton(step: -1)
//                    Text("•")
//                        .foregroundColor(Color(.quaternaryLabel))
                    unitBottomButton
                    stepButton(step: 1)
                    stepButton(step: 10)
                    stepButton(step: 50)
                }
                .frame(maxWidth: .infinity)
                saveButton
            }
            .padding(.bottom)
            .padding(.top, 10)
            /// ** REMOVE THIS HARDCODED VALUE for the safe area bottom inset **
            .padding(.bottom, 30)
        }
        .background(.thinMaterial)
    }
    
    var equivalentSection: some View {
        FormStyledSection(header: Text("Equivalent Amounts")) {
            Text("Show other values that this converts to as fill options which the user can tap to replace the amount with. So if they've typed in 1.5 serving, there would be an option for '3 pieces' (assuming a serving is 2 pieces), and another one saying '45 g' (assuming a piece is 15g). This serves the dual purposes of presenting the equivalent amounts to the user in addition to allowing them to select them to use them without converting it themselves. **Also include any density based conversions here**.")
                .foregroundColor(.secondary)
        }
    }
    
    var nutrientsSummarySection: some View {
        FormStyledSection(header: Text("Nutrients")) {
            Text("Let the user see at a glance of how much this amount would equate to in terms of its nutrients. Only show a summary here and let them tap on this cell to pop up a sheet with the Food Label and any further visualisations such as a pie chart etc.")
                .foregroundColor(.secondary)
        }
    }

    var goalIncrementSection: some View {
        FormStyledSection(header: Text("Daily Consumption")) {
            Text("Show how much this increases your daily consumption (against a goal if applicable).")
                .foregroundColor(.secondary)
        }
    }

    var mealIncrementSection: some View {
        FormStyledSection(header: Text("Meal Nutrients")) {
            Text("Show how much this increases the nutrients of the chosen meal (if its not the only item in it).")
                .foregroundColor(.secondary)
        }
    }

    var unitButton: some View {
        Button {
            showingUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(viewModel.unitDescription)
                    .font(.title)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.title3)
//                    .imageScale(.large)
            }
        }
        .buttonStyle(.borderless)
    }

    @ViewBuilder
    var unitPicker: some View {
        UnitPicker(
            pickedUnit: viewModel.unit,
            includeServing: viewModel.shouldShowServingInUnitPicker,
            sizes: viewModel.foodSizes,
            servingDescription: viewModel.servingDescription,
            allowAddSize: false,
            didPickUnit: viewModel.didPickUnit
        )
    }
    
    //MARK: - TextField Section
    
    var textFieldSection: some View {
        var footer: some View {
            Text("This is how much of this food you are logging.")
        }
        
        var header: some View {
            Text(viewModel.amountHeaderString)
        }
        
        return FormStyledSection(header: header, footer: footer) {
            HStack {
                textField
                unitButton
            }
        }
    }
    
    //MARK: - TextField
    
    var textField: some View {
        let binding = Binding<String>(
            get: { viewModel.amount?.cleanAmount ?? "" },
            set: {
                guard let double = Double($0) else {
                    viewModel.amount = nil
                    return
                }
                viewModel.amount = double
            }
        )
        
        return TextField("Required", text: binding)
            .multilineTextAlignment(.leading)
            .focused($isFocused)
            .font(textFieldFont)
            .keyboardType(.decimalPad)
            .frame(minHeight: 50)
            .scrollDismissesKeyboard(.interactively)
    }

    var textFieldFont: Font {
        viewModel.amount == nil ? .body : .largeTitle
    }

    
    //MARK: - Buttons
    
    var navigationLeadingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
//                /// Do nothing to revert the values as the original `FieldViewModel` is still untouched
//                doNotRegisterUserInput = true
//                dismiss()
            } label: {
                closeButtonLabel
            }
        }
    }

}

//MARK: - TO be moved


public extension FormSize {
    init?(foodSize: FoodSize, in sizes: [FoodSize]) {
        let volumePrefixUnit: FormUnit?
        if let volumePrefixExplicitUnit = foodSize.volumePrefixExplicitUnit {
            guard let formUnit = FormUnit(volumeExplicitUnit: volumePrefixExplicitUnit) else {
                return nil
            }
            volumePrefixUnit = formUnit
        } else {
            volumePrefixUnit = nil
        }
        
        guard let unit = FormUnit(foodValue: foodSize.value, in: sizes) else {
            return nil
        }
        
        self.init(
            quantity: foodSize.quantity,
            volumePrefixUnit: volumePrefixUnit,
            name: foodSize.name,
            amount: foodSize.value.value,
            unit: unit
        )
    }
}

public extension Array where Element == FoodSize {
    func sizeMatchingUnitSizeInFoodValue(_ foodValue: FoodValue) -> FoodSize? {
        first(where: { $0.id == foodValue.sizeUnitId })
    }
}

public extension FormUnit {
    
    init?(foodValue: FoodValue, in sizes: [FoodSize]) {
        switch foodValue.unitType {
        case .serving:
            self = .serving
        case .weight:
            guard let weightUnit = foodValue.weightUnit else {
                return nil
            }
            self = .weight(weightUnit)
        case .volume:
            guard let volumeUnit = foodValue.volumeExplicitUnit?.volumeUnit else {
                return nil
            }
            self = .volume(volumeUnit)
        case .size:
            guard let foodSize = sizes.sizeMatchingUnitSizeInFoodValue(foodValue),
                  let formSize = FormSize(foodSize: foodSize, in: sizes)
            else {
                return nil
            }
            self = .size(formSize, foodValue.sizeUnitVolumePrefixExplicitUnit?.volumeUnit)
        }
    }
    
    init?(volumeExplicitUnit: VolumeExplicitUnit) {
        self = .volume(volumeExplicitUnit.volumeUnit)
    }
}

public extension Food {
    var formSizes: [FormSize] {
        info.sizes.compactMap { foodSize in
            FormSize(foodSize: foodSize, in: info.sizes)
        }
    }
    
    var servingDescription: String? {
        guard let serving = info.serving else { return nil }
        return "\(serving.value.cleanAmount) \(serving.unitDescription(sizes: info.sizes))"
    }
}

public extension FoodValue {
    func unitDescription(sizes: [FoodSize]) -> String {
        switch self.unitType {
        case .serving:
            return "serving"
        case .weight:
            guard let weightUnit else {
                return "invalid weight"
            }
            return weightUnit.shortDescription
        case .volume:
            guard let volumeUnit = volumeExplicitUnit?.volumeUnit else {
                return "invalid volume"
            }
            return volumeUnit.shortDescription
        case .size:
            guard let size = sizes.sizeMatchingUnitSizeInFoodValue(self) else {
                return "invalid size"
            }
            if let volumePrefixUnit = size.volumePrefixExplicitUnit?.volumeUnit {
                return "\(volumePrefixUnit.shortDescription) \(size.name)"
            } else {
                return size.name
            }
        }
    }
}

