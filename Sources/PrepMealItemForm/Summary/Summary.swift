import SwiftUI
import SwiftUISugar
import FoodLabel
import PrepViews
import PrepDataTypes
import SwiftHaptics
import PrepCoreDataStack

public extension Notification.Name {
    static var didPickMeal: Notification.Name { return .init("didPickMeal") }
}

extension MealItemForm {
    struct Summary: View {
        
        @StateObject var viewModel: MealItemViewModel
        
        @Environment(\.colorScheme) var colorScheme
        
        @Binding var isPresented: Bool

        @State var canBeSaved = true
        
        public init(
            food: Food,
            meal: Meal? = nil,
            day: Day? = nil,
            dayMeals: [DayMeal] = [],
            isPresented: Binding<Bool>
        ) {
            let viewModel = MealItemViewModel(
                food: food,
                day: day,
                meal: meal,
                dayMeals: dayMeals
            )
            _viewModel = StateObject(wrappedValue: viewModel)

//            _path = path
            _isPresented = isPresented
        }
    }
}

extension MealItemForm.Summary {
    
    public var body: some View {
        Self._printChanges()
        return content
            .navigationTitle("Log Food")
            .toolbar { trailingCloseButton }
    }
    
    var content: some View {
        ZStack {
            formLayer
            buttonsLayer
        }
    }
    
    var formLayer: some View {
        FormStyledScrollView {
            foodSection
            mealSection
            textFieldSection
            metersSection
//            quantitySection
//            foodLabelSection
        }
        .safeAreaInset(edge: .bottom) { safeAreaInset }
    }
    
    var metersSection: some View {
        MealItemMeters(
            foodItem: $viewModel.mealFoodItem,
            meal: $viewModel.dayMeal,
            day: viewModel.day, //TODO: Get
            userUnits: DataManager.shared.user?.units ?? .standard,
//            bodyProfile: viewModel.day?.bodyProfile //TODO: We need to load the Day's bodyProfile here once supported
            bodyProfile: DataManager.shared.user?.bodyProfile
        )
    }
    
    @ViewBuilder
    var buttonsLayer: some View {
        if canBeSaved {
            VStack {
                Spacer()
                bottomButtons
            }
            .edgesIgnoringSafeArea(.bottom)
            .transition(.move(edge: .bottom))
        }
    }
    
    var mealPicker: some View {
        MealItemForm.MealPicker(isPresented: $isPresented) { pickedMeal in
            NotificationCenter.default.post(name: .didPickMeal, object: nil, userInfo: [Notification.Keys.meal: pickedMeal])
//            viewModel.meal = Meal(
//                id: pickedMeal.id,
//                day: viewModel.day!,
//                name: pickedMeal.name,
//                time: pickedMeal.time,
//                foodItems: pickedMeal.foodItems,
//                syncStatus: .notSynced,
//                updatedAt: 0
//            )
        }
        .environmentObject(viewModel)
    }
    
    var amountForm: some View {
        MealItemForm.QuantityForm(isPresented: $isPresented)
            .environmentObject(viewModel)
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
    
    var headerBackgroundColor: Color {
        colorScheme == .dark ?
        Color(.systemFill) :
        Color(.white)
    }
    
    @ViewBuilder
    var foodSection: some View {
        FormStyledSection {
            HStack {
                FoodCell(
                    food: viewModel.food,
                    showMacrosIndicator: false
                )
                Spacer()
                NutritionSummary(
                    dataProvider: viewModel,
                    showMacrosIndicator: true
                )
                .fixedSize(horizontal: true, vertical: false)
            }
        }
    }
    
    var mealSection: some View {
        FormStyledSection(header: Text("Meal")) {
            NavigationLink {
                mealPicker
            } label: {
                HStack {
                    Text("Pre-Workout Meal")
                        .foregroundColor(.primary)
                    Spacer()
                    Text("10:30 am")
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .fontWeight(.medium)
                        .foregroundColor(Color(.tertiaryLabel))
                }
//                Text("10:30 am • Pre-workout Meal")
                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .foregroundColor(.accentColor)
            }
        }
    }
    
    var quantitySection: some View {
        FormStyledSection(header: Text("Quantity")) {
            NavigationLink {
                amountForm
            } label: {
                HStack {
                    Text("1 cup, chopped")
                        .foregroundColor(.primary)
                    Spacer()
                    Text("250 g")
                        .foregroundColor(.secondary)
//                    MiniMeters()
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .fontWeight(.medium)
                        .foregroundColor(Color(.tertiaryLabel))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
//                .foregroundColor(.accentColor)
            }
        }
    }
    
    var foodLabelSection: some View {
        FormStyledSection {
            foodLabel
        }
    }
    
    @ViewBuilder
    var safeAreaInset: some View {
        if canBeSaved {
            Spacer()
                .frame(height: 180)
        }
    }
    
    var foodLabel: FoodLabel {
        let energyBinding = Binding<FoodLabelValue>(
            get: { .init(amount: 234, unit: .kcal)  },
            set: { _ in }
        )

        let carbBinding = Binding<Double>(
            get: { 56 },
            set: { _ in }
        )

        let fatBinding = Binding<Double>(
            get: { 38  },
            set: { _ in }
        )

        let proteinBinding = Binding<Double>(
            get: { 25 },
            set: { _ in }
        )
        
        let microsBinding = Binding<[NutrientType : FoodLabelValue]>(
            get: {
                [
                    .saturatedFat : .init(amount: 22, unit: .g),
                    .sugars : .init(amount: 28, unit: .g),
                    .calcium : .init(amount: 230, unit: .mg),
                    .sodium : .init(amount: 1640, unit: .mg),
                    .transFat : .init(amount: 2, unit: .g),
                    .dietaryFiber : .init(amount: 6, unit: .g)
                ]
            },
            set: { _ in }
        )
        
        let amountBinding = Binding<String>(
            get: { "1 cup, chopped" },
            set: { _ in }
        )

        return FoodLabel(
            energyValue: energyBinding,
            carb: carbBinding,
            fat: fatBinding,
            protein: proteinBinding,
            nutrients: microsBinding,
            amountPerString: amountBinding
        )
    }
    
    var textFieldSection: some View {
        var header: some View {
            Text(viewModel.amountHeaderString)
        }
        
        return FormStyledSection(header: header) {
            HStack {
                textField
                unitButton
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
        
        return TextField("Required", text: binding)
            .multilineTextAlignment(.leading)
//            .focused($isFocused)
//            .font(textFieldFont)
            .keyboardType(.decimalPad)
//            .frame(minHeight: 50)
            .scrollDismissesKeyboard(.interactively)
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                if let textField = obj.object as? UITextField {
                    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                }
            }
    }

    
    var unitButton: some View {
        Button {
//            showingUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(viewModel.unitDescription)
//                    .font(.title)
                    .multilineTextAlignment(.trailing)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
//                    .font(.title3)
//                    .imageScale(.large)
            }
        }
        .buttonStyle(.borderless)
    }
}

extension MealItemViewModel: NutritionSummaryProvider {
    var forMeal: Bool {
        false
    }
    
    var isMarkedAsCompleted: Bool {
        false
    }
    
    var showQuantityAsSummaryDetail: Bool {
        false
    }
    
    var energyAmount: Double {
        120
    }
    
    var carbAmount: Double {
        69
    }
    
    var fatAmount: Double {
        13
    }
    
    var proteinAmount: Double {
        45
    }
}
