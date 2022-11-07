import SwiftUI
import SwiftUISugar
import FoodLabel
import PrepViews
import PrepDataTypes
import SwiftHaptics

public struct MealItemForm: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let food: Food
    
    let namespace: Namespace.ID
    
    @Binding var path: [MealItemRoute]
    @Binding var isPresented: Bool

    @StateObject var viewModel = ViewModel()
    @State var canBeSaved = true
    @State var isPrepping: Bool
    
    @State var showingMealPicker = false
    @State var showingAmountForm = false

    @ObservedObject var newMealItem: TimelineItem
    let dayMeals: [DayMeal]

    var amount: Binding<Double?>
    var unit: Binding<FormUnit>
    
    public init(
        food: Food,
        path: Binding<[MealItemRoute]>,
        isPresented: Binding<Bool>,
        amount: Binding<Double?>,
        unit: Binding<FormUnit>,
        newMealItem: TimelineItem,
        dayMeals: [DayMeal],
        namespace: Namespace.ID
    ) {
        self.amount = amount
        self.unit = unit
        self.food = food
        self.newMealItem = newMealItem
        self.dayMeals = dayMeals
        _isPrepping = State(initialValue: Int.random(in: 0...1) == 0)
        _path = path
        _isPresented = isPresented
        self.namespace = namespace
    }
    
    public var body: some View {
        content
            .navigationTitle(isPrepping ? "Prep Food" : "Log Food")
            .sheet(isPresented: $showingMealPicker) { mealPicker }
            .sheet(isPresented: $showingAmountForm) { amountForm }
            .toolbar { trailingCloseButton }
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
    
    var content: some View {
        ZStack {
            formLayer
            buttonsLayer
        }
    }
    
    @ViewBuilder
    var buttonsLayer: some View {
        if canBeSaved {
            VStack {
                Spacer()
                saveButton
            }
            .edgesIgnoringSafeArea(.bottom)
            .transition(.move(edge: .bottom))
        }
    }
    
    var mealPicker: some View {
        NavigationView {
            MealItemForm.MealForm(
                mealItem: newMealItem,
                dayMeals: dayMeals,
                isPresented: $isPresented
            )
        }
    }
    
    var amountForm: some View {
        NavigationView {
            MealItemForm.AmountForm(
                food: food,
                amount: amount,
                unit: unit,
                isPresented: $isPresented,
                namespace: namespace
            )
        }
    }

    var headerBackgroundColor: Color {
        colorScheme == .dark ?
        Color(.systemFill) :
        Color(.white)
    }
    
    var formLayer: some View {
        FormStyledScrollView {
            FormStyledSection {
                HStack {
                    FoodCell(
                        food: food,
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
//            FormStyledSection(header: Text("Meal")) {
//                Text("10:30 am • Pre-workout Meal")
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .foregroundColor(.accentColor)
//            }
//            FormStyledSection(header: Text("Amount")) {
//                HStack {
//                    Text("1 cup, chopped • 250g")
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .foregroundColor(.accentColor)
//                }
//            }
            FormStyledSection {
                foodLabel
            }
        }
        .safeAreaInset(edge: .bottom) { safeAreaInset }
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

//struct MealItemFormPreview: View {
//    @State var path: [MealItemRoute] = []
//
//    var body: some View {
//        MealItemForm(food: Food(
//            mockName: "Carrots",
//            emoji: "🥕",
//            detail: "Baby",
//            brand: "Coles"
//        ), path: $path, newMealItem: <#T##TimelineItem#>)
//
//    }
//}
//
//struct MealItemForm_Previews: PreviewProvider {
//    static var previews: some View {
//        MealItemFormPreview()
//    }
//}

extension MealItemForm {
    class ViewModel: ObservableObject {
        
    }
}

extension MealItemForm.ViewModel: NutritionSummaryProvider {
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
        234
    }
    
    var carbAmount: Double {
        56
    }
    
    var fatAmount: Double {
        38
    }
    
    var proteinAmount: Double {
        25
    }
}
