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
        
        public init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
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
