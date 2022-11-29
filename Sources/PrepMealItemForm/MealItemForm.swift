import SwiftUI
import SwiftUISugar
import FoodLabel
import PrepViews
import PrepDataTypes
import SwiftHaptics
import PrepCoreDataStack
import PrepMocks
import PrepGoalSetsList

public extension Notification.Name {
    static var didPickMeal: Notification.Name { return .init("didPickMeal") }
}

public struct MealItemForm: View {
    @Environment(\.colorScheme) var colorScheme
    @FocusState var isFocused: Bool
    
    @State var showingUnitPicker = false
    @State var showingMealTypesPicker = false
    @State var showingDietsPicker = false
    
    @State var canBeSaved = true

    let alreadyInNavigationStack: Bool
    
    @ObservedObject var viewModel: MealItemViewModel
    @Binding var isPresented: Bool
    
    public init(meal: Meal? = nil, food: Food? = nil, day: Day? = nil, isPresented: Binding<Bool>) {
        let viewModel = MealItemViewModel(
            food: food,
            day: day,
            meal: meal,
            dayMeals: day?.meals ?? []
        )
        self.viewModel = viewModel
        _isPresented = isPresented
        alreadyInNavigationStack = false
    }
    
    public init(viewModel: MealItemViewModel, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        _isPresented = isPresented
        alreadyInNavigationStack = true
    }
}

public extension MealItemForm {
    
    @ViewBuilder
    var body: some View {
        Group {
            if alreadyInNavigationStack {
                content
            } else {
                navigationStack
            }
        }
    }
    
    var navigationStack: some View {
        NavigationStack(path: $viewModel.path) {
            content
                .navigationDestination(for: MealItemFormRoute.self, destination: navigationDestination)
        }
    }
    
    var content: some View {
        ZStack {
            formLayer
            VStack {
                Spacer()
                bottomButtons
            }
            .edgesIgnoringSafeArea(.bottom)
            .transition(.move(edge: .bottom))
        }
    }
    
    @ViewBuilder
    func navigationDestination(for route: MealItemFormRoute) -> some View {
        switch route {
        case .food:
            Search(
                viewModel: viewModel,
                isPresented: $isPresented
            )
        case .meal:
            mealPicker
        case .mealItemForm:
            EmptyView()
        }
    }
    
    //MARK: - Details
    
    var detailsSection: some View {
        var divider: some View {
            Divider()
                .padding(.top, 5)
                .padding(.bottom, 10)
                .padding(.leading, 50)
        }
        
        var amountRow: some View {
            HStack {
                Text("Amount")
                    .foregroundColor(.secondary)
                    .onTapGesture {
                        Haptics.feedback(style: .soft)
                        isFocused = true
                    }
                Spacer()
                textField
                unitButton
            }
        }
        
        return FormStyledSection(horizontalPadding: 0) {
            VStack {
                foodLink
                    .padding(.horizontal, 17)
                divider
                mealLink
                    .padding(.horizontal, 17)
                divider
                amountRow
                    .padding(.horizontal, 17)
                .padding(.bottom, 5)
            }
        }
    }
    
    @ViewBuilder
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

    
    @ViewBuilder
    var foodLink: some View {
        if let food = viewModel.food {
            Button {
                viewModel.path.append(.food)
            } label: {
                HStack {
                    FoodCell(
                        food: food,
                        showMacrosIndicator: false
                    )
                    .animation(.default, value: viewModel.mealFoodItem)
                    .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    NutritionSummary(
                        dataProvider: viewModel,
                        showMacrosIndicator: true
                    )
                    .animation(.default, value: viewModel.mealFoodItem)
                    .fixedSize(horizontal: true, vertical: false)
                    navigationLinkArrow
                }
                .multilineTextAlignment(.leading)
            }
        }
    }
    
    var mealLink: some View {
        Button {
            viewModel.path.append(.meal)
        } label: {
            HStack {
                Text("Meal")
                    .foregroundColor(.secondary)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(viewModel.dayMeal.name)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.accentColor)
                    Text(viewModel.dayMeal.timeString)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(Color(.secondarySystemFill))
                        )
                }
                navigationLinkArrow
            }
//                Text("10:30 am • Pre-workout Meal")
                .frame(maxWidth: .infinity, alignment: .leading)
//                    .foregroundColor(.accentColor)
        }
    }
    
    var formLayer: some View {
        form
            .safeAreaInset(edge: .bottom) { bottomSafeAreaInset }
            .navigationTitle("\(viewModel.saveButtonTitle) Food")
            .toolbar { trailingContents }
            .toolbar { leadingContents }
            .scrollDismissesKeyboard(.interactively)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showingUnitPicker) { unitPicker }
            .sheet(isPresented: $showingMealTypesPicker) { mealTypesPicker }
            .sheet(isPresented: $showingDietsPicker) { dietsPicker }
    }
    
    var mealTypesPicker: some View {
        Text("Meal Types Picker")
    }
    
    var dietsPicker: some View {
        NavigationView {
            GoalSetsList(
                showCloseButton: false,
                allowsSelection: true,
                forMealItemForm: true,
                selectedGoalSet: viewModel.day?.goalSet
            ) { tappedGoalSet in
                do {
                    //TODO: Only persist changes for goals once food item is added
                    guard let day = viewModel.day else { return }
                    if day.goalSet?.id == tappedGoalSet.id {
//                        try DataManager.shared.removeGoalSet(on: day.date)
                        viewModel.day?.goalSet = nil
                    } else {
//                        try DataManager.shared.setGoalSet(tappedGoalSet, on: day.date)
                        viewModel.day?.goalSet = tappedGoalSet
                    }
//                    NotificationCenter.default.post(name: .didUpdateDiet, object: nil)
                } catch {
                    print("Error setting GoalSet: \(error)")
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    var form: some View {
        FormStyledScrollView {
            detailsSection
            metersSection
        }
    }
    var bottomSafeAreaInset: some View {
        Spacer()
            .frame(height: 80)
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
    }
    
    func didTapGoalSetButton(forMeal: Bool) {
        if forMeal {
            showingMealTypesPicker = true
        } else {
            showingDietsPicker = true
        }
    }
    
    var mealPicker: some View {
        MealItemForm.MealPicker(isPresented: $isPresented) { pickedMeal in
            NotificationCenter.default.post(name: .didPickMeal, object: nil, userInfo: [Notification.Keys.meal: pickedMeal])
        }
        .environmentObject(viewModel)
    }
    
    var trailingContents: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if canBeSaved {
                Button {
                    Haptics.feedback(style: .soft)
                    //TODO: Actually save it
                    isPresented = false
                } label: {
                    Text("Add")
                }
            }
        }
    }

    var leadingContents: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                Haptics.feedback(style: .soft)
                isPresented = false
            } label: {
                closeButtonLabel
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
        
        var actualTextField: some View {
            TextField("Required", text: binding)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 16, weight: .regular, design: .default))
                .frame(height: 30)
                .focused($isFocused)
                .keyboardType(.decimalPad)
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                    if let textField = obj.object as? UITextField {
                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                    }
                }
        }
        
        var animatedNumber: some View {
            Color.clear
                .animatedMealItemAmount(value: viewModel.amount ?? 0)
        }
        
        return ZStack {
            if viewModel.isAnimatingAmountChange, viewModel.amount?.isInteger == true {
                animatedNumber
            } else {
                actualTextField
            }
        }
        .animation(.default, value: viewModel.amount)
    }

    
    var unitButton: some View {
        Button {
            showingUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(viewModel.unitDescription)
                    .multilineTextAlignment(.trailing)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
            }
        }
        .buttonStyle(.borderless)
    }
}

extension Double {
    var isInteger: Bool {
        floor(self) == self
    }
}

extension MealItemForm {
    
    var bottomButtons: some View {
        VStack(spacing: 0) {
            Divider()
            stepButtons
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .padding(.bottom, 35)
        }
        .background(.thinMaterial)
    }
    
    var dotSeparator: some View {
        Text("•")
            .font(.system(size: 20))
            .foregroundColor(Color(.quaternaryLabel))
    }
    
    var stepButtons: some View {
        HStack {
            stepButton(step: -50)
            stepButton(step: -10)
            stepButton(step: -1)
            dotSeparator
            unitBottomButton
            dotSeparator
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

struct AnimatableMealItemAmountModifier: AnimatableModifier {
    
    var value: Double
    
    let fontSize: CGFloat = 16
    
    var animatableData: Int {
        get { Int(value.rounded()) }
        set { value = Double(newValue) }
    }
    
    var uiFont: UIFont {
        UIFont.systemFont(ofSize: fontSize, weight: .regular)
    }
    
    var size: CGSize {
        uiFont.fontSize(for: value.cleanAmount)
    }

    func body(content: Content) -> some View {
        content
            .frame(width: 100, height: 30)
            .overlay(
                HStack {
                    Spacer()
                    Text(value.cleanAmount)
                        .font(.system(size: fontSize, weight: .regular, design: .default))
                        .offset(x: 1)
                }
            )
    }
}

extension Int: VectorArithmetic {
    mutating public func scale(by rhs: Double) {
        self = Int(Double(self) * rhs)
    }

    public var magnitudeSquared: Double {
        Double(self * self)
    }
}

extension View {
    func animatedMealItemAmount(value: Double) -> some View {
        modifier(AnimatableMealItemAmountModifier(value: value))
    }
}

//MARK: - 👁‍🗨 Previews

public struct MealItemFormPreview: View {
    var mockViewModel: MealItemViewModel {
        MealItemViewModel(
            food: FoodMock.peanutButter,
            day: DayMock.cutting,
            meal: MealMock.preWorkoutEmpty,
            dayMeals: []
        )
    }
    
    public init() { }
    
    public var body: some View {
        NavigationView {
            MealItemForm(
                viewModel: mockViewModel,
                isPresented: .constant(true)
            )
        }
    }
}

struct MealItemForm_Previews: PreviewProvider {
    static var previews: some View {
        MealItemFormPreview()
    }
}
