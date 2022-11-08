import SwiftUI
import SwiftHaptics
import PrepCoreDataStack
import PrepDataTypes
import PrepFoodSearch

public struct MealItemForm: View {
    
    @State var path: [MealItemRoute] = []
    @Binding var isPresented: Bool
    @State var foodToShowMacrosFor: Food? = nil

    let meal: Meal?
    let dayMeals: [DayMeal]
    
    public init(
        meal: Meal? = nil,
        dayMeals: [DayMeal] = [],
        isPresented: Binding<Bool>
    ) {
        self.meal = meal
        self.dayMeals = dayMeals
        _isPresented = isPresented
    }
    
    public var body: some View {
        NavigationStack(path: $path) {
            FoodSearch(
                dataProvider: DataManager.shared,
                didTapFood: {
                    Haptics.feedback(style: .soft)
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
                    summaryForm(for: food)
                default:
                    Color.red
                }
            }
            .sheet(item: $foodToShowMacrosFor) { macrosView(for: $0) }
        }
        .interactiveDismissDisabled(!path.isEmpty)
    }
    
    func summaryForm(for food: Food) -> some View {
        Summary(
            food: food,
            meal: meal,
            dayMeals: dayMeals,
            path: $path,
            isPresented: $isPresented
        )
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

