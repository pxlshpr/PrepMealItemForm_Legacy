import SwiftUI
import Timeline
import PrepDataTypes
import SwiftUISugar
import SwiftHaptics

extension MealItemForm {
    public struct MealPicker: View {
        
        @EnvironmentObject var viewModel: MealItemViewModel
        
        @Environment(\.dismiss) var dismiss
        @Binding var isPresented: Bool
      
        let didTapMeal: (DayMeal) -> ()
        public init(
            isPresented: Binding<Bool>,
            didTapMeal: @escaping ((DayMeal) -> ())
        ) {
            _isPresented = isPresented
            self.didTapMeal = didTapMeal
        }
    }
}

public extension MealItemForm.MealPicker {
    
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
                isPresented = false
            } label: {
                closeButtonLabel
            }
        }
    }

    func didTapOnNewItem() {
        
    }
}
