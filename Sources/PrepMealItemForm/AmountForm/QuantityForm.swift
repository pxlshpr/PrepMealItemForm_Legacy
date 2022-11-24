import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar
import PrepViews
import Combine

extension MealItemForm {
    public struct QuantityForm: View {
        
        @EnvironmentObject var viewModel: MealItemViewModel

        @Namespace var namespace
        @Environment(\.colorScheme) var colorScheme
        @Environment(\.dismiss) var dismiss
        @Binding var isPresented: Bool
        
        @FocusState var isFocused: Bool
        @State var animatedIsFocused: Bool = false
        @State var showingUnitPicker = false
        
        @State var showingEquivalentQuantitiesInGrid = false
        @State var equivalentQuantities: [FoodQuantity] = []
        
        public init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
        }
    }
}

public extension MealItemForm.QuantityForm {

    var body: some View {
        ZStack {
            content
            VStack {
                Spacer()
                bottomButtons
            }
//            .edgesIgnoringSafeArea(.bottom)
            .transition(.move(edge: .bottom))
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Quantity")
        .sheet(isPresented: $showingUnitPicker) { unitPicker }
        .toolbar { trailingCloseButton }
        .onAppear(perform: appeared)
        .onChange(of: isFocused, perform: isFocusedChanged)
    }
    
    func isFocusedChanged(to newValue: Bool) {
        withAnimation {
            animatedIsFocused = newValue
        }
    }
    
    func appeared() {
        isFocused = true
    }
    
    var content: some View {
        FormStyledScrollView {
            textFieldSection
            equivalentSection
            mealGoalsSection
            dailyGoalsSection
//            legendSection
//            mealIncrementSection
//            goalIncrementSection
//            nutrientsSummarySection
        }
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
}

extension MealItemForm.QuantityForm {
    var mealGoalsSection: some View {
        var header: some View {
            HStack {
                Text("Meal Goals")
                Spacer()
                Button {
                    
                } label: {
                    HStack {
                        Text("🏋🏽‍♂️ Pre-Workout")
                            .textCase(.none)
                        Image(systemName: "chevron.up.chevron.down")
                    }
                    .foregroundColor(.accentColor)
                }
            }
        }
        
        var footer: some View {
            Text("These are your goals for the chosen Meal Type and today’s Diet.")
        }
        
        return FormStyledSection(header: header) {
            Text("Food Meters go here")
        }
    }
}

extension MealItemForm.QuantityForm {
    var dailyGoalsSection: some View {
        var header: some View {
            HStack {
                Text("Daily Goals")
                Spacer()
                Button {
                    
                } label: {
                    HStack {
                        Text("🫃🏽 Weight Loss")
                            .textCase(.none)
                        Image(systemName: "chevron.up.chevron.down")
                    }
                    .foregroundColor(.accentColor)
                }
            }
        }
        
        var footer: some View {
            LegendView(
                prepped: [.energy, .fat, .protein, .carb],
                increments: [.energy, .fat, .protein, .carb],
                showCompletion: true,
                showExcess: true
            )
        }
        
        return FormStyledSection(header: header, footer: footer) {
            Text("Food Meters go here")
        }
    }
}

extension MealItemForm.QuantityForm {
    var legendSection: some View {
        FormStyledSection(header: Text("Legend")) {
            Text("Legend goes here")
        }
    }
}

struct LegendView: View {
    
    let prepped: [FoodMeterComponent]
    let increments: [FoodMeterComponent]
    let showCompletion: Bool
    let showExcess: Bool
    
    init(
        prepped: [FoodMeterComponent] = [],
        increments: [FoodMeterComponent] = [],
        showCompletion: Bool = false,
        showExcess: Bool = false
    ) {
        self.prepped = prepped
        self.increments = increments
        self.showCompletion = showCompletion
        self.showExcess = showExcess
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                preppedGrid
                    .padding(.top, Self.spacing)
                Text("This is what you've already added.")
            }
            HStack(alignment: .top) {
                incrementsGrid
                    .padding(.top, Self.spacing)
                Text("This is what this food will be adding.")
            }
        }
    }
    
    static let spacing: CGFloat = 2
    static let colorSize: CGFloat = 10
    let cornerRadius: CGFloat = 2
    
    static let gridItem = GridItem(.fixed(colorSize), spacing: spacing)
    static let gridLayout = [gridItem, gridItem, gridItem]
    
    var preppedGrid: some View {
        LazyVGrid(columns: Self.gridLayout, spacing: Self.spacing) {
            ForEach(prepped, id: \.self) {
                colorBox($0.preppedColor)
            }
            if showCompletion {
                colorBox(FoodMeter.ViewModel.Colors.Complete.placeholder)
            }
            if showExcess {
                colorBox(FoodMeter.ViewModel.Colors.Excess.placeholder)
            }
        }
        .fixedSize()
    }

    var incrementsGrid: some View {
        LazyVGrid(columns: Self.gridLayout, spacing: Self.spacing) {
            ForEach(increments, id: \.self) {
                colorBox($0.eatenColor)
            }
            if showCompletion {
                colorBox(FoodMeter.ViewModel.Colors.Complete.fill)
            }
            if showExcess {
                colorBox(FoodMeter.ViewModel.Colors.Excess.fill)
            }
        }
        .fixedSize()
    }

    func colorBox(_ color: Color) -> some View {
        color
            .frame(width: Self.colorSize, height: Self.colorSize)
            .cornerRadius(cornerRadius)
    }
}

struct LegendViewPreview: View {
    var body: some View {
        NavigationView {
            FormStyledScrollView {
                FormStyledSection(header: Text("Daily Goals"), footer: footer) {
                    Text("FoodMeters go here")
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
        }
    }
    
    var footer: some View {
        LegendView(
            prepped: [.energy, .fat, .protein, .carb],
            increments: [.energy, .fat, .protein, .carb],
            showCompletion: true,
            showExcess: true
        )
    }
}

struct LegendView_Previews: PreviewProvider {
    static var previews: some View {
        LegendViewPreview()
    }
}
