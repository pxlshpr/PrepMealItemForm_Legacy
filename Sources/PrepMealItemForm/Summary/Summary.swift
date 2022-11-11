import SwiftUI
import SwiftUISugar
import FoodLabel
import PrepViews
import PrepDataTypes
import SwiftHaptics

extension MealItemForm {
    struct Summary: View {
        
        @StateObject var viewModel: MealItemViewModel
        
        @Environment(\.colorScheme) var colorScheme
        
        @Binding var path: [MealItemRoute]
        @Binding var isPresented: Bool

        @State var canBeSaved = true
        
        @State var showingMealPicker = false
        @State var showingAmountForm = false
        
        public init(
            food: Food,
            meal: Meal? = nil,
            dayMeals: [DayMeal] = [],
            path: Binding<[MealItemRoute]>,
            isPresented: Binding<Bool>
        ) {
            let viewModel = MealItemViewModel(food: food, meal: meal, dayMeals: dayMeals)
            _viewModel = StateObject(wrappedValue: viewModel)

            _path = path
            _isPresented = isPresented
        }
    }
}

extension MealItemForm.Summary {
    
    public var body: some View {
        content
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
//            mealSection
//            quantitySection
            foodLabelSection
        }
        .safeAreaInset(edge: .bottom) { safeAreaInset }
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
        MealItemForm.MealPicker(isPresented: $isPresented)
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
            Text("10:30 am • Pre-workout Meal")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.accentColor)
        }
    }
    
    var quantitySection: some View {
        FormStyledSection(header: Text("Quantity")) {
            HStack {
                Text("1 cup, chopped • 250g")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.accentColor)
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
}
