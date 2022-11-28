import SwiftUI
import SwiftUISugar
import FoodLabel
import PrepViews
import PrepDataTypes
import SwiftHaptics
import PrepCoreDataStack
import PrepMocks

public extension Notification.Name {
    static var didPickMeal: Notification.Name { return .init("didPickMeal") }
}

public struct MealItemForm: View {
    @Environment(\.colorScheme) var colorScheme
    @State var canBeSaved = true
    
    @ObservedObject var viewModel: MealItemViewModel
    @Binding var isPresented: Bool
    
    @FocusState var isFocused: Bool
    
    let alreadyInNavigationStack: Bool
    
    public init(meal: Meal? = nil, food: Food? = nil, day: Day? = nil, isPresented: Binding<Bool>) {
        let viewModel = MealItemViewModel(
            food: food,
            day: day,
            meal: meal,
            dayMeals: day?.meals ?? []
        )
        self.viewModel = viewModel
        _isPresented = isPresented
        alreadyInNavigationStack = false
    }
    
    public init(viewModel: MealItemViewModel, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        _isPresented = isPresented
        alreadyInNavigationStack = true
    }
}

public extension MealItemForm {
    
    @ViewBuilder
    var body: some View {
        if alreadyInNavigationStack {
            content
        } else {
            navigationStack
        }
    }
    
    var navigationStack: some View {
        NavigationStack(path: $viewModel.path) {
            content
                .navigationDestination(for: MealItemFormRoute.self, destination: navigationDestination)
        }
    }
    
    var content: some View {
        formLayer
            .navigationTitle("\(viewModel.saveButtonTitle) Food")
            .toolbar { trailingContents }
            .toolbar { leadingContents }
            .scrollDismissesKeyboard(.interactively)
            .interactiveDismissDisabled(isFocused)
            .navigationBarBackButtonHidden(true)
//            .navigationDestination(for: MealItemFormRoute.self, destination: navigationDestination)
    }
    
    @ViewBuilder
    func navigationDestination(for route: MealItemFormRoute) -> some View {
        switch route {
        case .food:
            FoodSearch(
                viewModel: viewModel,
                isPresented: $isPresented
            )
        case .meal:
            mealPicker
        case .mealItemForm:
            EmptyView()
        }
    }
    
    @ViewBuilder
    var foodLink: some View {
        if let food = viewModel.food {
            Button {
                viewModel.path.append(.food)
            } label: {
                HStack {
                    FoodCell(
                        food: food,
                        showMacrosIndicator: false
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    NutritionSummary(
                        dataProvider: viewModel,
                        showMacrosIndicator: true
                    )
                    .fixedSize(horizontal: true, vertical: false)
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .fontWeight(.medium)
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
        }
    }
    
    var mealLink: some View {
        Button {
            viewModel.path.append(.meal)
        } label: {
            HStack {
                Text("Meal")
                    .foregroundColor(.secondary)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Pre-Workout Meal")
                        .foregroundColor(.accentColor)
                    Text("10:30 am")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(Color(.secondarySystemFill))
                        )
                }
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .fontWeight(.medium)
                    .foregroundColor(Color(.tertiaryLabel))
            }
//                Text("10:30 am • Pre-workout Meal")
                .frame(maxWidth: .infinity, alignment: .leading)
//                    .foregroundColor(.accentColor)
        }
    }
    
    var detailsSection: some View {
        FormStyledSection(horizontalPadding: 0) {
            VStack {
                foodLink
                    .padding(.horizontal, 20)
                
                Divider()
                    .padding(.top, 5)
                    .padding(.bottom, 10)
                    .padding(.leading, 50)

                mealLink
                .padding(.horizontal, 20)
                
                Divider()
                    .padding(.top, 5)
                    .padding(.bottom, 10)
                    .padding(.leading, 20)
                
                HStack {
                    Text("Amount")
                        .foregroundColor(.secondary)
                    Spacer()
                    textField
                    unitButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 5)
            }
        }
    }
    
    var formLayer: some View {
        FormStyledScrollView {
            detailsSection
//            foodSection
//            mealSection
//            textFieldSection
            metersSection
//            quantitySection
//            foodLabelSection
        }
//        .safeAreaInset(edge: .bottom) { safeAreaInset }
    }
    
    var metersSection: some View {
        MealItemMeters(
            foodItem: $viewModel.mealFoodItem,
            meal: $viewModel.dayMeal,
            day: viewModel.day, //TODO: Get
            userUnits: DataManager.shared.user?.units ?? .standard,
//            bodyProfile: viewModel.day?.bodyProfile //TODO: We need to load the Day's bodyProfile here once supported
            bodyProfile: DataManager.shared.user?.bodyProfile
        )
    }
    
    @ViewBuilder
    var buttonsLayer: some View {
        if canBeSaved {
            VStack {
                Spacer()
                bottomButtons
            }
            .edgesIgnoringSafeArea(.bottom)
            .transition(.move(edge: .bottom))
        }
    }
    
    var mealPicker: some View {
        MealItemForm.MealPicker(isPresented: $isPresented) { pickedMeal in
            NotificationCenter.default.post(name: .didPickMeal, object: nil, userInfo: [Notification.Keys.meal: pickedMeal])
        }
        .environmentObject(viewModel)
    }
    
    var amountForm: some View {
        MealItemForm.QuantityForm(isPresented: $isPresented)
            .environmentObject(viewModel)
    }

    var trailingContents: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if canBeSaved {
                Button {
//                    Haptics.feedback(style: .soft)
//                    isPresented = false
                } label: {
                    Text(viewModel.saveButtonTitle)
//                    closeButtonLabel
                }
            }
        }
    }

    var leadingContents: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                Haptics.feedback(style: .soft)
                isPresented = false
            } label: {
                closeButtonLabel
            }
        }
    }

    var headerBackgroundColor: Color {
        colorScheme == .dark ?
        Color(.systemFill) :
        Color(.white)
    }
    
    @ViewBuilder
    var foodSection: some View {
        if let food = viewModel.food {
            FormStyledSection {
                HStack {
                    FoodCell(
                        food: food,
                        showMacrosIndicator: false
                    )
                    Spacer()
                    NutritionSummary(
                        dataProvider: viewModel,
                        showMacrosIndicator: true
                    )
                    .fixedSize(horizontal: true, vertical: false)
                }
            }
        }
    }
    
    var mealSection: some View {
        FormStyledSection(header: Text("Meal")) {
            NavigationLink {
                mealPicker
            } label: {
                HStack {
                    Text("Pre-Workout Meal")
                        .foregroundColor(.primary)
                    Spacer()
                    Text("10:30 am")
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .fontWeight(.medium)
                        .foregroundColor(Color(.tertiaryLabel))
                }
//                Text("10:30 am • Pre-workout Meal")
                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .foregroundColor(.accentColor)
            }
        }
    }
    
    var quantitySection: some View {
        FormStyledSection(header: Text("Quantity")) {
            NavigationLink {
                amountForm
            } label: {
                HStack {
                    Text("1 cup, chopped")
                        .foregroundColor(.primary)
                    Spacer()
                    Text("250 g")
                        .foregroundColor(.secondary)
//                    MiniMeters()
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .fontWeight(.medium)
                        .foregroundColor(Color(.tertiaryLabel))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
//                .foregroundColor(.accentColor)
            }
        }
    }
    
    var foodLabelSection: some View {
        FormStyledSection {
            foodLabel
        }
    }
    
    @ViewBuilder
    var safeAreaInset: some View {
        if canBeSaved {
            Spacer()
                .frame(height: 180)
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
    
    var textFieldSection: some View {
        return FormStyledSection(header: Text(viewModel.amountHeaderString)) {
            HStack {
                textField
                unitButton
            }
        }
    }
    
    var textField: some View {
        let binding = Binding<String>(
            get: { viewModel.amountString },
            set: { newValue in
                withAnimation {
                    viewModel.amountString = newValue
                }
            }
        )
        
        return TextField("Required", text: binding)
            .multilineTextAlignment(.trailing)
            .focused($isFocused)
//            .font(textFieldFont)
//            .keyboardType(.decimalPad)
//            .frame(minHeight: 50)
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                if let textField = obj.object as? UITextField {
                    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                }
            }
    }

    
    var unitButton: some View {
        Button {
//            showingUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(viewModel.unitDescription)
//                    .font(.title)
                    .multilineTextAlignment(.trailing)
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
//                    .font(.title3)
//                    .imageScale(.large)
            }
        }
        .buttonStyle(.borderless)
    }
}

extension MealItemForm {

    func buttonLabel(
        heading: String,
        title: String?,
        detail: String? = nil
    ) -> some View {
        VStack(spacing: 0) {
            Text(heading)
                .textCase(.uppercase)
                .font(.caption2)
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 2)
                .background(
                    Color.accentColor
                )
            VStack {
                if let title {
                    Text(title)
                        .font(.headline)
                        .minimumScaleFactor(0.1)
                } else {
                    Text("Required")
                        .font(.headline)
                        .foregroundColor(Color(.quaternaryLabel))
                }
                if let detail {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.accentColor)
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 70)
            .background(
                .ultraThickMaterial
//                colorScheme == .light ? .ultraThickMaterial : .ultraThinMaterial
            )
        }
        .cornerRadius(10)
//        .shadow(color: Color.black, radius: 2, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(
                    Color.accentColor.opacity(0.7),
                    style: StrokeStyle(lineWidth: 0.5, dash: [3])
                )
        )
    }
    
    var bottomButtons: some View {
        var saveButton: some View {
            FormPrimaryButton(title: viewModel.saveButtonTitle) {
                print("We here")
            }
        }
        
        return VStack(spacing: 0) {
            Divider()
            VStack {
//                HStack {
//                    amountLink
//                    mealLink
//                }
//                .padding(.horizontal)
//                .padding(.horizontal)
                saveButton
            }
            .padding(.bottom)
            .padding(.top, 10)
            /// ** REMOVE THIS HARDCODED VALUE for the safe area bottom inset **
            .padding(.bottom, 30)
        }
        .background(.thinMaterial)
    }
    
//    var mealLink: some View {
//        NavigationLink {
//            mealPicker
//        } label: {
//            buttonLabel(
//                heading: "Meal",
//                title: mealTitle,
//                detail: mealDetail
//            )
//        }
//    }
    
    var amountLink: some View {
        NavigationLink {
            amountForm
        } label: {
            buttonLabel(
                heading: "Quantity",
                title: viewModel.amountTitle,
                detail: viewModel.amountDetail
            )
        }
    }
    
    var mealTitle: String? {
        Date().formatted(date: .omitted, time: .shortened).lowercased()
    }
    
    var mealDetail: String? {
        newMealName(for: Date())
    }
}

struct MealItemFormPreview: View {
    var mockViewModel: MealItemViewModel {
        MealItemViewModel(
            dayMeals: []
        )
    }
    
    var body: some View {
        NavigationView {
            MealItemForm(
                isPresented: .constant(true)
            )
        }
    }
}

struct MealItemForm_Previews: PreviewProvider {
    static var previews: some View {
        MealItemFormPreview()
    }
}
