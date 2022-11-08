import SwiftUI
import SwiftUISugar
import PrepDataTypes

extension MealItemForm.AmountForm {
    
    @ViewBuilder
    var quantitiesGrid: some View {
        if let quantities = viewModel.equivalentQuantities {
            FlowLayout(
                mode: .scrollable,
                items: quantities,
                itemSpacing: 4,
                shouldAnimateHeight: .constant(true)
            ) { quantity in
                quantityButton(for: quantity)
            }
        }
    }
    
    func quantityButton(for quantity: FoodQuantity) -> some View {
        Button {
            viewModel.didPickQuantity(quantity)
        } label: {
            ZStack {
                Capsule(style: .continuous)
                    .foregroundColor(Color(.secondarySystemFill))
                HStack(spacing: 5) {
                    Text(quantity.description)
                        .foregroundColor(.primary)
                }
                .frame(height: 25)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
            }
            .fixedSize(horizontal: true, vertical: true)
        }
    }
}

struct AmountFormPreview: View {
    @StateObject var viewModel = MealItemViewModel(food: .init(mockName: "Cheese", emoji: "🧀"), meal: nil, dayMeals: [])
    var body: some View {
        MealItemForm.AmountForm(isPresented: .constant(true))
            .environmentObject(viewModel)
    }
}

struct AmountForm_Previews: PreviewProvider {
    static var previews: some View {
        AmountFormPreview()
    }
}
