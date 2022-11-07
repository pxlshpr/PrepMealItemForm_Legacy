import SwiftUI
import SwiftUISugar
import FoodLabel
import PrepViews
import PrepDataTypes

public struct MealItemForm: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let food: Food
    
    @Binding var path: [MealItemRoute]
    
    @StateObject var viewModel = ViewModel()
    @State var canBeSaved = true
    @State var isPrepping: Bool
    
    public init(food: Food, path: Binding<[MealItemRoute]>) {
        self.food = food
        _isPrepping = State(initialValue: Int.random(in: 0...1) == 0)
        _path = path
    }
    
    public var body: some View {
        content
            .navigationTitle(isPrepping ? "Prep Food" : "Log Food")
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
    
    func buttonLabel(
        heading: String,
        title: String,
        detail: String? = nil
    ) -> some View {
        VStack(spacing: 2) {
            Text(heading)
                .textCase(.uppercase)
                .font(.caption2)
                .foregroundColor(Color(.tertiaryLabel))
            VStack {
                Text(title)
                    .font(.headline)
                if let detail {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.accentColor)
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(
                .thickMaterial
            )
            .cornerRadius(10)
        }
    }
    
    var amountButton: some View {
        Button {
            path.append(.amount(food))
        } label: {
            buttonLabel(
                heading: "Amount",
                title: "1 cup, chopped",
                detail: "250g"
            )
        }
    }

    var mealButton: some View {
        Button {
            path.append(.meal(food))
        } label: {
            buttonLabel(
                heading: "Meal",
                title: "10:30 am",
                detail: "Pre-workout Meal"
            )
        }
    }
    
    var saveButton: some View {
        var publicButton: some View {
            FormPrimaryButton(title: "\(isPrepping ? "Prep" : "Log")") {
                print("We here")
            }
        }
        
        return VStack(spacing: 0) {
            Divider()
            VStack {
                HStack {
                    amountButton
                    mealButton
                }
                .padding(.horizontal)
                .padding(.horizontal)
                publicButton
            }
            .padding(.bottom)
            .padding(.top, 10)
            /// ** REMOVE THIS HARDCODED VALUE for the safe area bottom inset **
            .padding(.bottom, 30)
        }
        .background(.thinMaterial)
    }

    var headerBackgroundColor: Color {
        colorScheme == .dark ?
        Color(.systemFill) :
        Color(.white)
    }
    
    var formLayer: some View {
        FormStyledScrollView {
            FormStyledSection(
//                backgroundColor: headerBackgroundColor
            ) {
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
//            FormStyledSection(header: Text("Meal")) {
//                Text("10:30 am • Pre-workout Meal")
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .foregroundColor(.accentColor)
//            }
//            FormStyledSection(header: Text("Amount")) {
//                HStack {
//                    Text("1 cup, chopped • 250g")
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .foregroundColor(.accentColor)
//                }
//            }
            FormStyledSection {
                foodLabel
            }
        }
        .safeAreaInset(edge: .bottom) { safeAreaInset }
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
}

struct MealItemFormPreview: View {
    @State var path: [MealItemRoute] = []
    
    var body: some View {
        MealItemForm(food: Food(
            mockName: "Carrots",
            emoji: "🥕",
            detail: "Baby",
            brand: "Coles"
        ), path: $path)
        
    }
}

struct MealItemForm_Previews: PreviewProvider {
    static var previews: some View {
        MealItemFormPreview()
    }
}

extension MealItemForm {
    class ViewModel: ObservableObject {
        
    }
}

extension MealItemForm.ViewModel: NutritionSummaryProvider {
    var forMeal: Bool {
        false
    }
    
    var isMarkedAsCompleted: Bool {
        false
    }
    
    var showQuantityAsSummaryDetail: Bool {
        false
    }
    
    var energyAmount: Double {
        234
    }
    
    var carbAmount: Double {
        56
    }
    
    var fatAmount: Double {
        38
    }
    
    var proteinAmount: Double {
        25
    }
}

#if canImport(UIKit)
import SwiftUI

let DefaultHorizontalPadding: CGFloat = 17
let DefaultVerticalPadding: CGFloat = 15

public struct FormStyledSection<Header: View, Footer: View, Content: View>: View {
    var header: Header?
    var footer: Footer?
    var backgroundColor: Color
    var content: () -> Content
    var verticalPadding: CGFloat?
    var horizontalPadding: CGFloat?

    public init(
        header: Header,
        footer: Footer,
        backgroundColor: Color = Color(.secondarySystemGroupedBackground),
        horizontalPadding: CGFloat? = nil,
        verticalPadding: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.footer = footer
        self.backgroundColor = backgroundColor
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.content = content
    }

    public var body: some View {
        if let header {
            if let footer {
                withHeader(header, andFooter: footer)
            } else {
                withHeaderOnly(header)
            }
        } else {
            if let footer {
                withFooterOnly(footer)
            } else {
                withoutHeaderOrFooter
            }
        }
    }

    func withHeader(_ header: Header, andFooter footer: Footer) -> some View {
        VStack(spacing: 7) {
            headerView(for: header)
            contentView
            footerView(for: footer)
                .padding(.bottom, 10)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    func withFooterOnly(_ footer: Footer) -> some View {
        VStack(spacing: 7) {
            contentView
            footerView(for: footer)
                .padding(.bottom, 10)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    func withHeaderOnly(_ header: Header) -> some View {
        VStack(spacing: 7) {
            headerView(for: header)
            contentView
                .padding(.bottom, 10)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }

    var withoutHeaderOrFooter: some View {
        contentView
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
    }
    
    //MARK: - Components
    
    func footerView(for footer: Footer) -> some View {
        footer
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(Color(.secondaryLabel))
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
    }
    
    func headerView(for header: Header) -> some View {
        header
            .foregroundColor(Color(.secondaryLabel))
            .font(.footnote)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
    }
    
    var contentView: some View {
        content()
//            .background(.green)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, horizontalPadding ?? DefaultHorizontalPadding)
            .padding(.vertical, verticalPadding ?? DefaultVerticalPadding)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(backgroundColor)
            )
    }
}

/// Support optional header
extension FormStyledSection where Header == EmptyView {
    public init(
        footer: Footer,
        backgroundColor: Color = Color(.secondarySystemGroupedBackground),
        horizontalPadding: CGFloat? = nil,
        verticalPadding: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = nil
        self.footer = footer
        self.backgroundColor = backgroundColor
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.content = content
    }
}

/// Support optional footer
extension FormStyledSection where Footer == EmptyView {
    public init(
        header: Header,
        backgroundColor: Color = Color(.secondarySystemGroupedBackground),
        horizontalPadding: CGFloat? = nil,
        verticalPadding: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.footer = nil
        self.backgroundColor = backgroundColor
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.content = content
    }
}


/// Support optional header and footer
extension FormStyledSection where Header == EmptyView, Footer == EmptyView {
    public init(
        backgroundColor: Color = Color(.secondarySystemGroupedBackground),
        horizontalPadding: CGFloat? = nil,
        verticalPadding: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = nil
        self.footer = nil
        self.backgroundColor = backgroundColor
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.content = content
    }
}

struct FormStyledSectionPreview: View {
    var footer: some View {
        Text("Provide a source if you want. Also this is now a very long footer lets see how this looks now shall we.")
    }
    
    
    var header: some View {
        Text("Header")
    }
    
    var body: some View {
        FormStyledScrollView {
            footerSection
            headerSection
            headerAndFooterSection
            noHeaderOrFooterSection
            headerSection
            footerSection
            noHeaderOrFooterSection
            headerAndFooterSection
        }
    }

    var headerSection: some View {
        FormStyledSection(header: header) {
            HStack {
                Text("Header only")
                Spacer()
            }
        }
    }

    var noHeaderOrFooterSection: some View {
        FormStyledSection {
            HStack {
                Text("No Header or Footer")
                Spacer()
            }
        }
    }
    var headerAndFooterSection: some View {
        FormStyledSection(header: header, footer: footer) {
            HStack {
                Text("Header and Footer")
                Spacer()
            }
        }
    }

    var footerSection: some View {
        FormStyledSection(footer: footer) {
            HStack {
                Text("Footer only")
                Spacer()
            }
        }
    }
}

struct FormStyledSection_Previews: PreviewProvider {
    static var previews: some View {
        FormStyledSectionPreview()
    }
}
#endif
