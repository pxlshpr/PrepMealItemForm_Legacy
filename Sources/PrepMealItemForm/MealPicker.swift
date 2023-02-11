import SwiftUI
import Timeline
import PrepDataTypes
import SwiftUISugar
import SwiftHaptics

public struct MealItemFormMealPicker: View {
    
    @EnvironmentObject var viewModel: MealItemViewModel
    
    @Environment(\.dismiss) var dismiss
  
    let didTapMeal: (DayMeal) -> ()
    let didTapDismiss: () -> ()

    public init(
        didTapDismiss: @escaping () -> (),
        didTapMeal: @escaping ((DayMeal) -> ())
    ) {
        self.didTapDismiss = didTapDismiss
        self.didTapMeal = didTapMeal
    }
}

public extension MealItemFormMealPicker {
    
    var body: some View {
        Timeline(
            items: viewModel.timelineItems,
            newItem: nil, //mealItem,
            shouldStylizeTappableItems: true,
            didTapItem: didTapItem,
            didTapOnNewItem: didTapOnNewItem
        )
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Pick a Meal")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { trailingCloseButton }
    }
    
    func didTapItem(_ item: TimelineItem) {
        Haptics.feedback(style: .rigid)
        if let meal = viewModel.dayMeals.first(where: { $0.id.uuidString == item.id }) {
            didTapMeal(meal)
        }
        dismiss()
    }

    var trailingCloseButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                Haptics.feedback(style: .soft)
                didTapDismiss()
            } label: {
                closeButtonLabel
            }
        }
    }

    func didTapOnNewItem() {
        
    }
}
