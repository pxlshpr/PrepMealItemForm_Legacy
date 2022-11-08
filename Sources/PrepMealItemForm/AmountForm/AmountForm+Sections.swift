import SwiftUI
import SwiftUISugar

extension MealItemForm.AmountForm {
    var textFieldSection: some View {
        var footer: some View {
            Text("This is how much of this food you are logging.")
        }
        
        var header: some View {
            Text(viewModel.amountHeaderString)
        }
        
        return FormStyledSection(header: header, footer: footer) {
            HStack {
                textField
                unitButton
            }
        }
    }
}

//TODO: Bring these in one by one
extension MealItemForm.AmountForm {
    
    var equivalentSection: some View {
        FormStyledSection(header: Text("Equivalent Amounts")) {
            Text("Show other values that this converts to as fill options which the user can tap to replace the amount with. So if they've typed in 1.5 serving, there would be an option for '3 pieces' (assuming a serving is 2 pieces), and another one saying '45 g' (assuming a piece is 15g). This serves the dual purposes of presenting the equivalent amounts to the user in addition to allowing them to select them to use them without converting it themselves. **Also include any density based conversions here**.")
                .foregroundColor(.secondary)
        }
    }
    
    var nutrientsSummarySection: some View {
        FormStyledSection(header: Text("Nutrients")) {
            Text("Let the user see at a glance of how much this amount would equate to in terms of its nutrients. Only show a summary here and let them tap on this cell to pop up a sheet with the Food Label and any further visualisations such as a pie chart etc.")
                .foregroundColor(.secondary)
        }
    }

    var goalIncrementSection: some View {
        FormStyledSection(header: Text("Daily Consumption")) {
            Text("Show how much this increases your daily consumption (against a goal if applicable).")
                .foregroundColor(.secondary)
        }
    }

    var mealIncrementSection: some View {
        FormStyledSection(header: Text("Meal Nutrients")) {
            Text("Show how much this increases the nutrients of the chosen meal (if its not the only item in it).")
                .foregroundColor(.secondary)
        }
    }
}
