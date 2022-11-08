import SwiftUI
import Timeline
import PrepDataTypes
import SwiftUISugar
import SwiftHaptics

extension MealItemForm {
    public struct MealForm: View {
        
        @EnvironmentObject var viewModel: MealItemForm.ViewModel
        
        @Environment(\.dismiss) var dismiss
        @Binding var isPresented: Bool
        
        public init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
        }
    }
}

public extension MealItemForm.MealForm {
    
    var body: some View {
        Timeline(
            items: viewModel.timelineItems,
            newItem: nil, //mealItem,
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
