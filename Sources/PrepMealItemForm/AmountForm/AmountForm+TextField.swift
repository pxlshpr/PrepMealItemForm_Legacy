import SwiftUI
import Combine
import PrepViews

extension MealItemForm.AmountForm {
    
    var textField: some View {
        let binding = Binding<String>(
            get: { viewModel.amount?.cleanAmount ?? "" },
            set: {
                guard let double = Double($0) else {
                    viewModel.amount = nil
                    return
                }
                viewModel.amount = double
            }
        )
        
        return TextField("Required", text: binding)
            .multilineTextAlignment(.leading)
            .focused($isFocused)
            .font(textFieldFont)
            .keyboardType(.decimalPad)
            .frame(minHeight: 50)
            .scrollDismissesKeyboard(.interactively)
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                if let textField = obj.object as? UITextField {
                    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                }
            }
    }

    
    var unitButton: some View {
        Button {
            showingUnitPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(viewModel.unitDescription)
                    .font(.title)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.title3)
//                    .imageScale(.large)
            }
        }
        .buttonStyle(.borderless)
    }
    
    @ViewBuilder
    var unitPicker: some View {
        UnitPicker(
            pickedUnit: viewModel.unit,
            includeServing: viewModel.shouldShowServingInUnitPicker,
            sizes: viewModel.foodSizes,
            servingDescription: viewModel.servingDescription,
            allowAddSize: false,
            didPickUnit: viewModel.didPickUnit
        )
    }
    
    var textFieldFont: Font {
        viewModel.amount == nil ? .body : .largeTitle
    }

}
