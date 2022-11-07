import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar
import PrepFoodForm

extension FormSize {
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

extension Array where Element == FoodSize {
    func sizeMatchingUnitSizeInFoodValue(_ foodValue: FoodValue) -> FoodSize? {
        first(where: { $0.id == foodValue.sizeUnitId })
    }
}
extension FormUnit {
    
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

extension Food {
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

extension FoodValue {
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
        
        let food: Food
        
        @Binding var amount: Double
        @Binding var unit: FormUnit

        @FocusState var isFocused: Bool
        @State var showingUnitPicker = false
        
        public init(food: Food, amount: Binding<Double>, unit: Binding<FormUnit>) {
            self.food = food
            _amount = amount
            _unit = unit
        }
    }
}

public extension MealItemForm.AmountForm {

    var body: some View {
        content
            .navigationTitle("Amount")
            .sheet(isPresented: $showingUnitPicker) { unitPicker }
            .onAppear {
                isFocused = true
            }
    }
    
    var content: some View {
        FormStyledScrollView {
            textFieldSection
            equivalentSection
            nutrientsSummarySection
            goalIncrementSection
            mealIncrementSection
        }
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
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }

    var unitPicker: some View {
        UnitPicker(
            pickedUnit: unit,
            includeServing: true,
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
//        switch field.value.doubleValue.unit {
//        case .serving:
            return "Servings"
//        case .weight:
//            return "Weight"
//        case .volume:
//            return "Volume"
//        case .size:
//            return "Size"
//        }
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
            get: { amount.cleanAmount },
            set: {
                guard let double = Double($0) else {
                    return
                }
                amount = double
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
//        return field.value.string.isEmpty ? .body : .largeTitle
        return .body
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
    
    var navigationTrailingContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            saveButton
        }
    }
    
    @ViewBuilder
    var saveButton: some View {
        Button("Save") {
//            saveAndDismiss()
        }
//        .disabled(!isDirty)
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
