import SwiftUI
import SwiftUISugar
import FoodLabel
import PrepViews

public struct MealItemForm: View {
    
    @StateObject var nutrientBreakdownViewModel: NutrientBreakdown.ViewModel
    
    public init() {
        let energy = FoodMeter.ViewModel(
            component: .energy,
            goal: 2000,
            burned: 0,
            food: 1200,
            eaten: nil,
            increment: 50
        )
        let carb = FoodMeter.ViewModel(
            component: .carb,
            goal: 280,
            burned: 0,
            food: 195,
            eaten: nil,
            increment: 80
        )
        let fat = FoodMeter.ViewModel(
            component: .fat,
            goal: 90,
            burned: 0,
            food: 35,
            eaten: nil,
            increment: 27
        )
        let protein = FoodMeter.ViewModel(
            component: .protein,
            goal: 180,
            burned: 0,
            food: 100,
            eaten: nil,
            increment: 50
        )

        var viewModel = NutrientBreakdown.ViewModel(
            energyViewModel: energy,
            carbViewModel: carb,
            fatViewModel: fat,
            proteinViewModel: protein
        )
        
//        @Published var haveGoal: Bool = true
//        @Published var showingDetails: Bool = false
//        @Published var includeBurnedCalories: Bool = true
        
        _nutrientBreakdownViewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            content
                .navigationTitle(Int.random(in: 0...1) == 0 ? "Prep Food" : "Log Food")
                .navigationBarTitleDisplayMode(.large)
        }
    }
    
    var content: some View {
        FormStyledScrollView {
            FormStyledSection {
                Text("🥕 Carrots, Organic, Woolworths")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            FormStyledSection(header: Text("Meal")) {
                Text("10:30 am • Pre-workout Meal")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            FormStyledSection(header: Text("Amount")) {
                Text("1 cup, chopped • 250g")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Divider().padding(.vertical)
            FormStyledSection(header: goalsHeader) {
                NutrientBreakdown(viewModel: nutrientBreakdownViewModel)
                Text("Goal increment goes here")
                    .foregroundColor(Color(.tertiaryLabel))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            FormStyledSection {
                Text("Food Label goes here")
                    .foregroundColor(Color(.tertiaryLabel))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .safeAreaInset(edge: .bottom) { safeAreaInset }
        .onAppear {
            nutrientBreakdownViewModel.haveGoal = true
            nutrientBreakdownViewModel.showingDetails = false
            nutrientBreakdownViewModel.includeBurnedCalories = false
        }
    }
    
    @State var showingTotal = true
    var goalsHeader: some View {
        HStack {
            Text("How this affects your goal")
            Spacer()
            Button(showingTotal ? "DAY" : "FOOD") {
                withAnimation {
                    showingTotal.toggle()
                }
            }
            .foregroundColor(.accentColor)
        }
    }
    
    @ViewBuilder
    var safeAreaInset: some View {
        if canBeSaved {
            Spacer()
                .frame(height: 100)
        }
    }
    
    var canBeSaved: Bool {
        false
    }
}

struct MealItemFormPreview: View {
    var body: some View {
        MealItemForm()
    }
}

struct MealItemForm_Previews: PreviewProvider {
    static var previews: some View {
        MealItemFormPreview()
    }
}
