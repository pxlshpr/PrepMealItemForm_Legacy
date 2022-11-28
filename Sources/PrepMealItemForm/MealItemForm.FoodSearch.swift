import SwiftUI
import SwiftHaptics
import PrepCoreDataStack
import PrepDataTypes
import PrepFoodSearch

public extension MealItemForm {
    
    struct FoodSearch: View {
        
        @State var path: [Route] = []
        @Binding var isPresented: Bool
        @State var foodToShowMacrosFor: Food? = nil
        
        @StateObject var viewModel: MealItemViewModel
        
        let day: Day?
        let meal: Meal?
        let dayMeals: [DayMeal]
        
        public init(
            meal: Meal? = nil,
            dayMeals: [DayMeal] = [],
            day: Day?,
            isPresented: Binding<Bool>
        ) {
            self.meal = meal
            self.dayMeals = dayMeals
            self.day = day
            _isPresented = isPresented
            
            let viewModel = MealItemViewModel(
                food: nil,
                day: day,
                meal: meal,
                dayMeals: dayMeals
            )
            _viewModel = StateObject(wrappedValue: viewModel)
        }
    }
}

extension MealItemForm.FoodSearch {
    
    public var body: some View {
        NavigationStack(path: $path) {
            FoodSearch(
                dataProvider: DataManager.shared,
                didTapFood: {
                    Haptics.feedback(style: .soft)
                    viewModel.food = $0
                    path = [Route.form]
                },
                didTapMacrosIndicatorForFood: {
                    Haptics.feedback(style: .soft)
                    foodToShowMacrosFor = $0
                }
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .form:
                    form
                }
            }
            .sheet(item: $foodToShowMacrosFor) { macrosView(for: $0) }
        }
        .interactiveDismissDisabled(!path.isEmpty)
    }
    
    var form: some View {
        MealItemForm(
            viewModel: viewModel,
            isPresented: $isPresented
        )
    }
    
    func macrosView(for food: Food) -> some View {
        Text("Macros for: \(food.name)")
            .presentationDetents([.medium, .large])
    }
    
    public enum Route: Hashable {
        case form
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

