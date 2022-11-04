import SwiftUI
import SwiftUISugar
import FoodLabel
import PrepViews
import PrepDataTypes

public struct MealItemForm: View {
    
    @StateObject var nutrientBreakdownViewModel: NutrientBreakdown.ViewModel
    @State var canBeSaved = true
    @State var isPrepping: Bool
    
    public init() {
        let energy = FoodMeter.ViewModel(
            component: .energy,
            goal: 2000,
            burned: 0,
            food: 50,
            eaten: nil,
            increment: 0
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
        _isPrepping = State(initialValue: Int.random(in: 0...1) == 0)
    }
    
    public var body: some View {
        NavigationView {
            content
                .navigationTitle(isPrepping ? "Prep Food" : "Log Food")
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    refresh()
                }
        }
    }
    
    var content: some View {
        ZStack {
            formLayer
            buttonsLayer
        }
    }
    
    @ViewBuilder
    var buttonsLayer: some View {
        if canBeSaved {
            VStack {
                Spacer()
                saveButton
            }
            .edgesIgnoringSafeArea(.bottom)
            .transition(.move(edge: .bottom))
        }
    }
    
    var saveButton: some View {
        var publicButton: some View {
            FormPrimaryButton(title: "\(isPrepping ? "Prep" : "Log")") {
                print("We here")
                refresh()
//                guard let data = foodFormOutput(shouldPublish: true) else {
//                    return
//                }
//                didSave(data)
//                dismiss()
            }
        }
        
        return VStack(spacing: 0) {
            Divider()
            VStack {
                publicButton
                    .padding(.vertical)
            }
            /// ** REMOVE THIS HARDCODED VALUE for the safe area bottom inset **
            .padding(.bottom, 30)
        }
        .background(.thinMaterial)
    }

    var formLayer: some View {
        FormStyledScrollView {
            FormStyledSection {
                Text("🥕 Carrots, Organic, Woolworths")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            FormStyledSection(header: Text("Meal")) {
                Text("10:30 am • Pre-workout Meal")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.accentColor)
            }
            FormStyledSection(header: Text("Amount")) {
                Text("1 cup, chopped • 250g")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.accentColor)
            }
            Divider().padding(.vertical)
            FormStyledSection(header: goalsHeader) {
                NutrientBreakdown(viewModel: nutrientBreakdownViewModel)
            }
            FormStyledSection {
                foodLabel
            }
        }
        .safeAreaInset(edge: .bottom) { safeAreaInset }
        .onAppear {
            nutrientBreakdownViewModel.haveGoal = true
            nutrientBreakdownViewModel.showingDetails = false
            nutrientBreakdownViewModel.includeBurnedCalories = false
            nutrientBreakdownViewModel.includeHeaderRow = false
        }
    }
    
    @State var showingTotal = true
    var goalsHeader: some View {
        HStack {
            Text("How this \(isPrepping ? "will affect" : "affects") your goal")
            Spacer()
            Text("Remaining")
                .foregroundColor(Color(.tertiaryLabel))
        }
    }
    
    func refresh() {
        withAnimation(.interactiveSpring()) {
            let energyGoal = Double.random(in: 1500...2500)
            nutrientBreakdownViewModel.energyViewModel.goal = energyGoal
            nutrientBreakdownViewModel.energyViewModel.food = Double.random(in: 0...energyGoal)
            nutrientBreakdownViewModel.energyViewModel.increment = Double.random(in: 0...1000)
            
            let carbGoal = Double.random(in: 80...350)
            nutrientBreakdownViewModel.carbViewModel.goal = carbGoal
            nutrientBreakdownViewModel.carbViewModel.food = Double.random(in: 0...carbGoal)
            nutrientBreakdownViewModel.carbViewModel.increment = Double.random(in: 0...200)

            let fatGoal = Double.random(in: 20...120)
            nutrientBreakdownViewModel.fatViewModel.goal = fatGoal
            nutrientBreakdownViewModel.fatViewModel.food = Double.random(in: 0...fatGoal)
            nutrientBreakdownViewModel.fatViewModel.increment = Double.random(in: 0...100)

            let proteinGoal = Double.random(in: 90...270)
            nutrientBreakdownViewModel.proteinViewModel.goal = proteinGoal
            nutrientBreakdownViewModel.proteinViewModel.food = Double.random(in: 0...proteinGoal)
            nutrientBreakdownViewModel.proteinViewModel.increment = Double.random(in: 0...100)

        }
    }

    @ViewBuilder
    var safeAreaInset: some View {
        if canBeSaved {
            Spacer()
                .frame(height: 100)
        }
    }
    
    var foodLabel: FoodLabel {
        let energyBinding = Binding<FoodLabelValue>(
            get: { .init(amount: 234, unit: .kcal)  },
            set: { _ in }
        )

        let carbBinding = Binding<Double>(
            get: { 56 },
            set: { _ in }
        )

        let fatBinding = Binding<Double>(
            get: { 38  },
            set: { _ in }
        )

        let proteinBinding = Binding<Double>(
            get: { 25 },
            set: { _ in }
        )
        
        let microsBinding = Binding<[NutrientType : FoodLabelValue]>(
            get: {
                [
                    .saturatedFat : .init(amount: 22, unit: .g),
                    .sugars : .init(amount: 28, unit: .g),
                    .calcium : .init(amount: 230, unit: .mg),
                    .sodium : .init(amount: 1640, unit: .mg),
                    .transFat : .init(amount: 2, unit: .g),
                    .dietaryFiber : .init(amount: 6, unit: .g)
                ]
            },
            set: { _ in }
        )
        
        let amountBinding = Binding<String>(
            get: { "1 cup, chopped" },
            set: { _ in }
        )

        return FoodLabel(
            energyValue: energyBinding,
            carb: carbBinding,
            fat: fatBinding,
            protein: proteinBinding,
            nutrients: microsBinding,
            amountPerString: amountBinding
        )
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
