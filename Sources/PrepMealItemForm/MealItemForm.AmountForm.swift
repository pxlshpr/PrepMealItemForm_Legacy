import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar
import PrepViews

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

extension MealItemForm {
    public struct AmountForm: View {
        
        @Environment(\.colorScheme) var colorScheme
        
        let food: Food
        
        var amount: Binding<Double?>
        @Binding var unit: FormUnit

        @FocusState var isFocused: Bool
        @State var showingUnitPicker = false
        
        public init(food: Food, amount: Binding<Double?>, unit: Binding<FormUnit>) {
            self.food = food
            self.amount = amount
            _unit = unit
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
        .navigationTitle("Amount")
        .sheet(isPresented: $showingUnitPicker) { unitPicker }
        .onAppear {
//            isFocused = true
        }
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
    
    func stepButton(step: Int) -> some View {
        Button {
            Haptics.feedback(style: .soft)
            let amount = self.amount.wrappedValue ?? 0
            self.amount.wrappedValue = amount + Double(step)
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
        .disabled(!amountCanBeStepped(by: step))
    }
    
    var unitBottomButton: some View {
        Button {
            Haptics.feedback(style: .soft)
            showingUnitPicker = true
        } label: {
            Image(systemName: "chevron.up.chevron.down")
                .imageScale(.large)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(colorScheme == .light ? .ultraThickMaterial : .ultraThinMaterial)
                .background(Color.accentColor)
                .cornerRadius(10)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10, style: .continuous)
//                        .stroke(
//                            Color.accentColor.opacity(0.7),
//                            style: StrokeStyle(lineWidth: 0.5, dash: [3])
//                        )
//                )
        }
    }
    
    func amountCanBeStepped(by step: Int) -> Bool {
        let amount = self.amount.wrappedValue ?? 0
        return amount + Double(step) > 0
    }
    
    var bottomButtons: some View {
        var saveButton: some View {
            FormSecondaryButton(title: "Done") {
                Haptics.feedback(style: .rigid)
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
                Text(unit.shortDescription)
                    .font(.title)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.title3)
//                    .imageScale(.large)
            }
        }
        .buttonStyle(.borderless)
    }

    var unitPicker: some View {
        UnitPicker(
            pickedUnit: unit,
            includeServing: food.info.serving != nil,
            sizes: food.formSizes,
            servingDescription: food.servingDescription,
            allowAddSize: false,
            didPickUnit:
                { unit in
                    setUnit(unit)
                }
        )
    }

    func setNewValue(_ value: FoodLabelValue) {
//        setAmount(value.amount)
//        setUnit(value.unit?.formUnit ?? .serving)
//        fields.updateFormState()
    }

    func setAmount(_ amount: Double) {
//        field.value.doubleValue.double = amount
    }

    func didSave() {
//        fields.amountChanged()
    }

    func setUnit(_ unit: FormUnit) {
        self.unit = unit
    }

    var headerString: String {
        unit.unitType.description
    }
    
    //MARK: - TextField Section
    
    var textFieldSection: some View {
        var footer: some View {
            Text("This is how much of this food you are logging.")
        }
        
        var header: some View {
            Text(headerString)
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
            get: { amount.wrappedValue?.cleanAmount ?? "" },
            set: {
                guard let double = Double($0) else {
                    amount.wrappedValue = nil
                    return
                }
                amount.wrappedValue = double
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
        amount.wrappedValue == nil ? .body : .largeTitle
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


struct MealItemAmountFormPreview: View {
    var body: some View {
        NavigationStack {
            MealItemForm.AmountForm(
                food: Food(mockName: "Cheese", emoji: "🧀"),
                amount: .constant(1),
                unit: .constant(.weight(.g))
            )
        }
    }
}

struct MealItemAmountForm_Previews: PreviewProvider {
    static var previews: some View {
        MealItemAmountFormPreview()
    }
}
