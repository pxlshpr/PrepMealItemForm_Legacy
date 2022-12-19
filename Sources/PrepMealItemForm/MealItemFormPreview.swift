import SwiftUI
import PrepDataTypes

extension Food {
    var primaryMacro: Macro {
        let carb = info.nutrients.carb
        let fat = info.nutrients.fat
        let protein = info.nutrients.protein
        let carbCalories = carb * 4.0
        let fatCalories = fat * 9.0
        let proteinCalories = protein * 4.0
        if carbCalories > fatCalories && carbCalories > proteinCalories {
            return .carb
        }
        if fatCalories > carbCalories && fatCalories > proteinCalories {
            return .fat
        }
//        if proteinCalories > fatCalories && proteinCalories > carbCalories {
//            return .protein
//        }
        return .protein
    }
    
    var hasDetail: Bool {
        detail != nil && !detail!.isEmpty
    }
    var hasBrand: Bool {
        brand != nil && !brand!.isEmpty
    }

    var hasDetails: Bool {
        hasDetail || hasBrand
    }
}

struct MealItemFormNew: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: MealItemViewModel

    var body: some View {
        scrollView
    }
    
    var disclosureArrow: some View {
        Image(systemName: "chevron.forward")
            .font(.system(size: 14))
            .foregroundColor(Color(.tertiaryLabel))
            .fontWeight(.semibold)
    }
    
    func foodCell(_ food: Food) -> some View {
        var emoji: some View {
            Text(food.emoji)
        }
        
        var macroColor: Color {
            return food.primaryMacro.textColor(for: colorScheme)
        }
        
        var detailTexts: some View {
            var view = Text("")
            if let detail = food.detail, !detail.isEmpty {
                view = view
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                + Text(detail)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            if let brand = food.brand, !brand.isEmpty {
                view = view
                + Text(", ")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                + Text(brand)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
            }
            return view
                .foregroundColor(.secondary)
        }
        
        return ZStack {
            HStack {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer().frame(width: 2)
                        HStack(spacing: 4) {
                            Text("Food")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        Spacer()
                        emoji
                        disclosureArrow
                    }
                    VStack(alignment: .leading) {
                        Text(food.name)
                                .foregroundColor(macroColor)
                            .font(.system(size: 28, weight: .medium, design: .rounded))
                        if food.hasDetails {
                            detailTexts
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 13)
        .padding(.top, 13)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .padding(.bottom, 10)
    }
    
    var mealCell: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer().frame(width: 2)
                        HStack(spacing: 4) {
                            Text("Meal")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        Spacer()
                        Text(viewModel.dayMeal.timeString)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .bold()
                            .foregroundColor(Color(.secondaryLabel))
                        disclosureArrow
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(viewModel.dayMeal.name)
                            .font(.system(size: 28, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 13)
        .padding(.top, 13)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .padding(.bottom, 10)
    }
    
    var amountCell: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer().frame(width: 2)
                        HStack(spacing: 4) {
                            Text("Quantity")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        Spacer()
                        disclosureArrow
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(viewModel.amountString)
                            .foregroundColor(.primary)
                            .font(.system(size: 28, weight: .medium, design: .rounded))
                            Text(viewModel.unitDescription)
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .bold()
                                .foregroundColor(Color(.secondaryLabel))
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 13)
        .padding(.top, 13)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .padding(.bottom, 10)
    }
    
    var scrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if let food = viewModel.food {
                    Button {
                        viewModel.path.append(.food)
                    } label: {
                        foodCell(food)
                    }
                }
                Button {
                    viewModel.path.append(.meal)
                } label: {
                    mealCell
                }
                Button {
                    viewModel.path.append(.quantity)
                } label: {
                    amountCell
                }
            }
            .padding(.horizontal, 20)
            .safeAreaInset(edge: .bottom) {
                Spacer()
                    .frame(height: 60)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

import PrepViews
import SwiftUISugar

extension MealItemForm {
    struct Quantity: View {
        @ObservedObject var viewModel: MealItemViewModel
        @FocusState var isFocused: Bool
        @State var showingUnitPicker = false
    }
}

extension MealItemForm.Quantity {
    var body: some View {
        FormStyledScrollView {
            textFieldSection
        }
        .navigationTitle("Quantity")
        .sheet(isPresented: $showingUnitPicker) { unitPicker }
        .onAppear(perform: appeared)
    }
    
    func appeared() {
        isFocused = true
    }
    
    var textFieldSection: some View {
        return Group {
            FormStyledSection {
                HStack {
                    textField
                    unitView
                }
            }
        }
    }
    
    var textField: some View {
        let binding = Binding<String>(
            get: { viewModel.amountString },
            set: { newValue in
                withAnimation {
                    viewModel.amountString = newValue
                }
            }
        )
        
        var font: Font {
            return viewModel.amountString.isEmpty ? .body : .largeTitle
        }

        return TextField("Required", text: binding)
            .multilineTextAlignment(.leading)
            .focused($isFocused)
            .font(font)
            .keyboardType(.decimalPad)
            .frame(minHeight: 50)
            .scrollDismissesKeyboard(.interactively)
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                if let textField = obj.object as? UITextField {
                    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                }
            }
    }
    
    var unitView: some View {
        var unitButton: some View {
            Button {
                showingUnitPicker = true
            } label: {
                HStack(spacing: 5) {
                    Text(viewModel.unitDescription)
                        .multilineTextAlignment(.trailing)
//                        .foregroundColor(.secondary)
                        .font(.title3)
                    Image(systemName: "chevron.up.chevron.down")
                        .imageScale(.small)
                }
                .bold()
            }
            .buttonStyle(.borderless)
        }
        
        return Group {
//            if supportedUnits.count > 1 {
                unitButton
//            } else {
//                Text(viewModel.unitDescription)
//                    .multilineTextAlignment(.trailing)
//                    .foregroundColor(.secondary)
//                    .font(.title3)
//            }
        }
    }
    
    var unitPicker: some View {
        UnitPickerGridTiered(
            pickedUnit: viewModel.unit.formUnit,
            includeServing: viewModel.shouldShowServingInUnitPicker,
            includeWeights: viewModel.shouldShowWeightUnits,
            includeVolumes: viewModel.shouldShowVolumeUnits,
            sizes: viewModel.foodSizes,
            servingDescription: viewModel.servingDescription,
            allowAddSize: false,
            didPickUnit: viewModel.didPickUnit
        )
    }
}
