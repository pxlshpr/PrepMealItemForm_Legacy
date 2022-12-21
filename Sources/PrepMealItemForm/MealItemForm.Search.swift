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

        @State var searchIsFocused: Bool = false

        let actionHandler: (MealItemFormAction) -> ()
//        let didTapSave: ((MealFoodItem, DayMeal) -> ())?
//        let didTapDismiss: (() -> ())

        public init(
            viewModel: MealItemViewModel,
            isInitialFoodSearch: Bool = false,
            actionHandler: @escaping (MealItemFormAction) -> ()
//            didTapDismiss: @escaping () -> (),
//            didTapSave: ((MealFoodItem, DayMeal) -> ())? = nil
        ) {
            self.viewModel = viewModel
            self.isInitialFoodSearch = isInitialFoodSearch
            self.actionHandler = actionHandler
//            self.didTapDismiss = didTapDismiss
//            self.didTapSave = didTapSave
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
//        .interactiveDismissDisabled(!viewModel.path.isEmpty || searchIsFocused)
    }

    var navigationStack: some View {
        NavigationStack(path: $viewModel.path) {
            foodSearch
            .navigationDestination(for: MealItemFormRoute.self) { route in
                switch route {
                case .mealItemForm:
                    MealItemForm(
                        viewModel: viewModel,
                        isEditing: false,
                        actionHandler: actionHandler
//                        didTapDismiss: didTapDismiss,
//                        didTapSave: didTapSave
                    )
                case .food:
                    MealItemForm.Search(
                        viewModel: viewModel,
                        actionHandler: actionHandler
//                        didTapDismiss: didTapDismiss
                    )
                case .meal:
                    mealPicker
                case .quantity:
                    MealItemForm.Quantity(viewModel: viewModel)
                }
            }
        }
    }
    
    var mealPicker: some View {
        MealItemForm.MealPicker(didTapDismiss: {
            actionHandler(.dismiss)
        }, didTapMeal: { pickedMeal in
            NotificationCenter.default.post(
                name: .didPickDayMeal,
                object: nil,
                userInfo: [Notification.Keys.dayMeal: pickedMeal]
            )
        })
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
            actionHandler(.dismiss)
        }
        
        return FoodSearch(
            dataProvider: DataManager.shared,
            shouldDelayContents: isInitialFoodSearch,
            focusOnAppear: isInitialFoodSearch,
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

