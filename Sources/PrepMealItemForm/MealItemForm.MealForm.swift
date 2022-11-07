import SwiftUI
import Timeline
import PrepDataTypes
import SwiftUISugar
import SwiftHaptics

extension MealItemForm {
    public struct MealForm: View {
        
        @Environment(\.dismiss) var dismiss
        
        @StateObject var viewModel = ViewModel()
        
        let timelineItems: [TimelineItem]
        let mealItem: TimelineItem?
        
        public init(mealItem: TimelineItem?, dayMeals: [DayMeal]) {
            self.timelineItems = dayMeals.map { TimelineItem(dayMeal: $0) }
            self.mealItem = mealItem
        }
    }
}

extension MealItemForm.MealForm {
    class ViewModel: ObservableObject {
        @Published var tappedMealItem: TimelineItem? = nil
    }
}

extension MealItemForm.MealForm.ViewModel: TimelineDelegate {
    func didTapNow() {
        
    }
    
    func didTapItem(_ item: TimelineItem) {
        tappedMealItem = item
    }
    
    func shouldRegisterTapsOnItems() -> Bool {
        true
    }
    
    func shouldStylizeTappableItems() -> Bool {
        true
    }
}

public extension MealItemForm.MealForm {
    /**
     We need the following modifications to `Timeline`.
     [x] In `Timeline`, make the Now button have a custom highlight where it doesn't go transparent so that we don't see the connector beneath it. Start with `SearchableViewButtonStyle` but add an alternative color, grayscale effect and/or a shadow that makes it pop up when we have it selected.
     [x] In `Timeline`, add an option to allow the user to select the `Timeline` items as well, in which case they be styled with the accent color dotted line around their boxes, and have the entire cell tappable—returning to the user so that it can be used as a `MealPicker`.
     [ ] Abstract out `PrepMealForm.TimeForm` into a `TimelinePicker` that can be reused by both it and this form. It should house the buttons to move the time back and forth, confirm the selection, the "Now" button, etc.
     [ ] Now use that to create an abstracted out `MealPicker` that we can use here or elsewhere—that basically takes an option of being able to create a new meal (which we will use here), but as a basic feature, allows the user to make a selection from the meals provided. This could be used when moving food item's between meals later.
     */
    var body: some View {
        Timeline(
            items: timelineItems,
            newItem: nil, //mealItem,
            didTapOnNewItem: didTapOnNewItem,
            delegate: viewModel
        )
        .navigationTitle("Pick a Meal")
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: viewModel.tappedMealItem, perform: { newValue in
            guard let newValue else  { return }
            Haptics.successFeedback()
            dismiss()
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    closeButtonLabel
                }
            }
        }
    }
    
    func didTapOnNewItem() {
        
    }
}
