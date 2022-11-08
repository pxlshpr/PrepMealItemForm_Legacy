import SwiftUI
import SwiftHaptics
import PrepCoreDataStack
import PrepDataTypes
import PrepFoodSearch

public struct MealItemForm: View {
    
    class ViewModel: ObservableObject {
        @Published var food: Food? = nil
        @Published var meal: Meal? = nil
        
        @Published var amount: Double? = 1
        @Published var unit: FormUnit = .serving
        
        @Published var dayMeals: [DayMeal]
        
        init(meal: Meal? = nil, dayMeals: [DayMeal]) {
            self.meal = meal
            self.dayMeals = dayMeals
        }
        
        var timelineItems: [TimelineItem] {
            dayMeals.map { TimelineItem(dayMeal: $0) }
        }
        
        var amountTitle: String? {
            guard let amount else {
                return nil
            }
            return "\(amount.cleanAmount) \(unit.shortDescription)"
        }
        
        var amountDetail: String? {
            //TODO: Get the primary equivalent value here
            ""
        }
        
        var saveButtonTitle: String {
            guard let meal else {
                return "Prep"
            }
            return meal.day.date < Date() ? "Log" : "Prep"
        }
        
        func stepAmount(by step: Int) {
            let amount = self.amount ?? 0
            self.amount = amount + Double(step)
        }
        
        func amountCanBeStepped(by step: Int) -> Bool {
            let amount = self.amount ?? 0
            return amount + Double(step) > 0
        }
        
        var unitDescription: String {
            unit.shortDescription
        }
        
        var shouldShowServingInUnitPicker: Bool {
            food?.info.serving != nil
        }
        
        var foodSizes: [FormSize] {
            food?.formSizes ?? []
        }
        
        var servingDescription: String? {
            food?.servingDescription
        }
        
        func didPickUnit(_ unit: FormUnit) {
            self.unit = unit
        }
        
        var amountHeaderString: String {
            unit.unitType.description
        }
    }
    
    @StateObject var viewModel: ViewModel
    
    @State var path: [MealItemRoute] = []
    @Binding var isPresented: Bool
    @State var foodToShowMacrosFor: Food? = nil

    public init(
        meal: Meal? = nil,
        dayMeals: [DayMeal] = [],
        isPresented: Binding<Bool>
    ) {
        _isPresented = isPresented
        let viewModel = ViewModel(meal: meal, dayMeals: dayMeals)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack(path: $path) {
            FoodSearch(
                dataProvider: DataManager.shared,
                didTapFood: {
                    Haptics.feedback(style: .soft)
                    //TODO: Set this to the last amount the user had used for this food if available
                    viewModel.food = $0
                    viewModel.unit = $0.defaultFormUnit
                    path = [MealItemRoute.summary($0)]
                },
                didTapMacrosIndicatorForFood: {
                    Haptics.feedback(style: .soft)
                    foodToShowMacrosFor = $0
                }
            )
            .navigationDestination(for: MealItemRoute.self) { route in
                switch route {
                case .summary(let food):
                    mealItemForm(for: food)
                case .amount(let food):
                    amountForm(for: food)
                case .meal(let food):
                    mealForm(for: food)
                }
            }
            .sheet(item: $foodToShowMacrosFor) { macrosView(for: $0) }
        }
        .interactiveDismissDisabled(!path.isEmpty)
    }
    
    func mealItemForm(for food: Food) -> some View {
        Summary(path: $path, isPresented: $isPresented)
            .environmentObject(viewModel)
    }
    
    func amountForm(for food: Food) -> some View {
        AmountForm(isPresented: $isPresented)
            .environmentObject(viewModel)
    }
    
    func mealForm(for food: Food) -> some View {
        MealForm(isPresented: $isPresented)
            .environmentObject(viewModel)
    }
    
    func macrosView(for food: Food) -> some View {
        Text("Macros for: \(food.name)")
            .presentationDetents([.medium, .large])
    }
}

extension Food {
    var defaultFormUnit: FormUnit {
        if let _ = info.serving {
            return .serving
        } else if let formUnit = FormUnit(foodValue: info.amount, in: info.sizes) {
            return formUnit
        } else {
            return .weight(.g)
        }
    }
}

import PrepViews

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
