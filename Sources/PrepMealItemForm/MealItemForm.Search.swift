import SwiftUI
import SwiftHaptics
import PrepCoreDataStack
import PrepDataTypes
import PrepFoodSearch

public extension MealItemForm {
    
    struct Search: View {
        
        @Environment(\.dismiss) var dismiss
        @State var foodToShowMacrosFor: Food? = nil
        
        let isInitialFoodSearch: Bool
        
        @ObservedObject var viewModel: MealItemViewModel
        @Binding var isPresented: Bool
        
        @State var searchIsFocused: Bool = false
        
        let didTapSave: ((MealFoodItem, DayMeal) -> ())?

        public init(
            date: Date,
            day: Day? = nil,
            dayMeal: DayMeal? = nil,
            isPresented: Binding<Bool>,
            didTapSave: ((MealFoodItem, DayMeal) -> ())? = nil
        ) {
            self.init(
                date: date,
                day: day,
                dayMeal: dayMeal,
                viewModel: nil,
                isPresented: isPresented,
                didTapSave: didTapSave
            )
        }

        public init(
            viewModel: MealItemViewModel,
            isPresented: Binding<Bool>,
            didTapSave: ((MealFoodItem, DayMeal) -> ())? = nil
        ) {
            self.init(
                date: viewModel.date,
                day: nil,
                dayMeal: nil,
                viewModel: viewModel,
                isPresented: isPresented,
                didTapSave: didTapSave
            )
        }

        private init(
            date: Date,
            day: Day? = nil,
            dayMeal: DayMeal? = nil,
            viewModel: MealItemViewModel? = nil,
            isPresented: Binding<Bool>,
            didTapSave: ((MealFoodItem, DayMeal) -> ())? = nil
        ) {
            self.didTapSave = didTapSave
            self.isInitialFoodSearch = viewModel == nil
            if let viewModel {
                self.viewModel = viewModel
            } else {
                let newViewModel = MealItemViewModel(
                    existingMealFoodItem: nil,
                    date: date,
                    day: day,
                    dayMeal: dayMeal,
                    dayMeals: day?.meals ?? []
                )
                _viewModel = ObservedObject(initialValue: newViewModel)
            }
            _isPresented = isPresented
        }
    }
}

extension MealItemForm.Search {
    
    @ViewBuilder
    public var body: some View {
        Group {
            if isInitialFoodSearch {
                navigationStack
            } else {
                foodSearch
            }
        }
        //TODO: Bring this back once we can tell if the search field is focused and
//        .interactiveDismissDisabled(!viewModel.path.isEmpty)
        .interactiveDismissDisabled(!viewModel.path.isEmpty || searchIsFocused)
    }

    var navigationStack: some View {
        NavigationStack(path: $viewModel.path) {
            foodSearch
            .navigationDestination(for: MealItemFormRoute.self) { route in
                switch route {
                case .mealItemForm:
                    MealItemForm(
                        viewModel: viewModel,
                        isPresented: $isPresented,
                        didTapSave: didTapSave
                    )
                case .food:
                    MealItemForm.Search(
                        viewModel: viewModel,
                        isPresented: $isPresented
                    )
                case .meal:
                    mealPicker
                }
            }
        }
    }
    
    var mealPicker: some View {
        MealItemForm.MealPicker(isPresented: $isPresented) { pickedMeal in
            NotificationCenter.default.post(name: .didPickMeal, object: nil, userInfo: [Notification.Keys.dayMeal: pickedMeal])
        }
        .environmentObject(viewModel)
    }

    var foodSearch: some View {
        func didTapFood(_ food: Food) {
            Haptics.feedback(style: .soft)
            viewModel.setFood(food)

            if isInitialFoodSearch {
                viewModel.path = [.mealItemForm]
            } else {
                dismiss()
            }
        }
        
        func didTapMacrosIndicatorForFood(_ food: Food) {
            Haptics.feedback(style: .soft)
            foodToShowMacrosFor = food
        }
        
        func didTapClose() {
            Haptics.feedback(style: .soft)
            isPresented = false
        }
        
        return FoodSearch(
            dataProvider: DataManager.shared,
            shouldDelayContents: isInitialFoodSearch,
            searchIsFocused: $searchIsFocused,
            didTapClose: didTapClose,
            didTapFood: didTapFood,
            didTapMacrosIndicatorForFood: didTapMacrosIndicatorForFood
        )
        .sheet(item: $foodToShowMacrosFor) { macrosView(for: $0) }
        .navigationBarBackButtonHidden(viewModel.food == nil)
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

