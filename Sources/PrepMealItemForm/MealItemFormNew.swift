import SwiftUI
import PrepDataTypes
import PrepCoreDataStack
import SwiftHaptics

struct MealItemFormNew: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: MealItemViewModel
    
    @State var showingQuantityForm = false

    var body: some View {
        scrollView
            .sheet(isPresented: $showingQuantityForm) { quantityForm }
    }
    
    var scrollView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                Group {
                    foodButton
                    mealButton
                    amountButton
                    stepButtons
                }
                .padding(.horizontal, 20)
                Divider()
                    .padding(.top, 20)
                metersSection
            }
            .safeAreaInset(edge: .bottom) {
                Spacer()
                    .frame(height: 60)
            }
        }
        .scrollContentBackground(.hidden)
        .background(background)
    }
    
    @ViewBuilder
    var foodButton: some View {
        if let food = viewModel.food {
            Button {
                viewModel.path.append(.food)
            } label: {
                foodCell(food)
            }
        }
    }
    
    var mealButton: some View {
        Button {
            viewModel.path.append(.meal)
        } label: {
            mealCell
        }
    }
    
    var amountButton: some View {
        Button {
            showingQuantityForm = true
//                    viewModel.path.append(.quantity)
        } label: {
            amountCell
        }
    }
    
    var metersSection: some View {
        MealItemMeters(
            foodItem: $viewModel.mealFoodItem,
            meal: $viewModel.dayMeal,
            day: $viewModel.day,
            userUnits: DataManager.shared.user?.units ?? .standard,
//            bodyProfile: viewModel.day?.bodyProfile //TODO: We need to load the Day's bodyProfile here once supported
            bodyProfile: DataManager.shared.user?.bodyProfile,
            didTapGoalSetButton: didTapGoalSetButton
        )
        .padding(.top, 15)
    }
    
    func didTapGoalSetButton(forMeal: Bool) {
//        if forMeal {
//            showingMealTypesPicker = true
//        } else {
//            showingDietsPicker = true
//        }
    }

    var background: some View {
        FormBackground()
            .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    var quantityForm: some View {
        if let food = viewModel.food {
            QuantityForm(
                food: food,
                double: viewModel.amountValue.value,
                unit: viewModel.unit.formUnit
            ) { double, unit in
                viewModel.amount = double
                viewModel.didPickUnit(unit)
            }
        }
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
                + Text(food.hasDetail ? ", " : "")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                + Text(brand)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
            }
            return view
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
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
                            .multilineTextAlignment(.leading)
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
//        .background(Color(.secondarySystemGroupedBackground))
        .background(FormCellBackground())
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
//        .background(Color(.secondarySystemGroupedBackground))
        .background(FormCellBackground())
        .cornerRadius(10)
        .padding(.bottom, 10)
    }
    
    var stepButtons: some View {
        func stepButton(step: Int) -> some View {
            var number: String {
                "\(abs(step))"
            }
            var sign: String {
                step > 0 ? "+" : "-"
            }
            
            var disabled: Bool {
                !viewModel.amountCanBeStepped(by: step)
            }
            var fontWeight: Font.Weight {
                disabled ? .thin : .semibold
            }
            
            return Button {
                Haptics.feedback(style: .soft)
                viewModel.stepAmount(by: step)
            } label: {
                HStack(spacing: 1) {
                    Text(sign)
                        .font(.system(.caption, design: .rounded, weight: .regular))
//                        .font(.system(size: 13, weight: .regular, design: .rounded))
                    Text(number)
                        .font(.system(.footnote, design: .rounded, weight: fontWeight))
//                        .font(.system(size: 11, weight: fontWeight, design: .rounded))
                }
                .monospacedDigit()
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
    //            .frame(width: 44, height: 44)
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
            .disabled(disabled)
        }
        
        return HStack {
            stepButton(step: -50)
            stepButton(step: -10)
            stepButton(step: -1)
            stepButton(step: 1)
            stepButton(step: 10)
            stepButton(step: 50)
        }
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
                        if viewModel.amountIsValid {
                            Color.clear
                                .animatedMealItemQuantity(
                                    value: viewModel.internalAmountDouble!,
                                    unitString: viewModel.unitDescription,
                                    isAnimating: viewModel.isAnimatingAmountChange
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
//                            Text(viewModel.amountString)
//                                .foregroundColor(.primary)
//                                .font(.system(size: 28, weight: .medium, design: .rounded))
//                            Text(viewModel.unitDescription)
//                                .font(.system(size: 17, weight: .semibold, design: .rounded))
//                                .bold()
//                                .foregroundColor(Color(.secondaryLabel))
                        } else {
                            Text("Required")
                                .foregroundColor(Color(.tertiaryLabel))
                                .font(.system(size: 28, weight: .medium, design: .rounded))
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 13)
        .padding(.top, 13)
//        .background(Color(.secondarySystemGroupedBackground))
        .background(FormCellBackground())
        .cornerRadius(10)
        .padding(.bottom, 10)
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

struct AnimatableMealItemQuantityModifier: AnimatableModifier {
    
    var value: Double
    var unitString: String
    var isAnimating: Bool
    
    let fontSize: CGFloat = 28
    let fontWeight: Font.Weight = .medium
    
    var animatableData: Double {
        get { value }
        set { value = newValue }
    }
    
    var uiFont: UIFont {
        UIFont.systemFont(ofSize: fontSize, weight: fontWeight.uiFontWeight)
    }
    
    var size: CGSize {
        uiFont.fontSize(for: value.formattedNutrient)
    }
    
    let unitFontSize: CGFloat = 17
    let unitFontWeight: Font.Weight = .semibold
    
    var unitUIFont: UIFont {
        UIFont.systemFont(ofSize: unitFontSize, weight: unitFontWeight.uiFontWeight)
    }
    
    var unitWidth: CGFloat {
        unitUIFont.fontSize(for: unitString).width
    }
    
    var amountString: String {
        if isAnimating {
            print("isAnimating, so returning \(value.formattedMealItemAmount)")
            return value.formattedMealItemAmount
        } else {
            print("NOT isAnimating, so returning \(value.cleanAmount)")
            return value.cleanAmount
        }
    }
    
    func body(content: Content) -> some View {
        content
//            .frame(width: size.width, height: size.height)
            .frame(width: 200 + unitWidth, height: size.height)
            .overlay(
                HStack(alignment: .firstTextBaseline, spacing: 3) {
//                    Text(viewModel.amountString)
//                        .foregroundColor(.primary)
//                        .font(.system(size: 28, weight: .medium, design: .rounded))
//                    Text(viewModel.unitDescription)
//                        .font(.system(size: 17, weight: .semibold, design: .rounded))
//                        .bold()
//                        .foregroundColor(Color(.secondaryLabel))
                    
                    Text(amountString)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                        .font(.system(size: fontSize, weight: fontWeight, design: .rounded))
                    Text(unitString)
                        .font(.system(size: unitFontSize, weight: unitFontWeight, design: .rounded))
                        .bold()
                        .foregroundColor(Color(.secondaryLabel))
//                        .offset(y: -0.5)

//                    Text(value.formattedNutrient)
//                        .font(.system(size: fontSize, weight: fontWeight, design: .default))
//                        .multilineTextAlignment(.leading)
//                        .foregroundColor(color)
//                    Text(unitString)
//                        .font(.system(size: unitFontSize, weight: unitFontWeight, design: .default))
//                        .foregroundColor(color.opacity(0.5))
//                        .offset(y: -0.5)
                    Spacer()
                }
            )
    }
}

public extension View {
    func animatedMealItemQuantity(value: Double, unitString: String, isAnimating: Bool) -> some View {
        modifier(AnimatableMealItemQuantityModifier(value: value, unitString: unitString, isAnimating: isAnimating))
    }
}
