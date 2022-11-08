import SwiftUI
import PrepDataTypes
import SwiftUISugar

extension MealItemForm.Summary {
    
    
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
                HStack {
                    amountLink
                    mealLink
                }
                .padding(.horizontal)
                .padding(.horizontal)
                saveButton
            }
            .padding(.bottom)
            .padding(.top, 10)
            /// ** REMOVE THIS HARDCODED VALUE for the safe area bottom inset **
            .padding(.bottom, 30)
        }
        .background(.thinMaterial)
    }
    
    var mealLink: some View {
        NavigationLink {
            mealPicker
        } label: {
            buttonLabel(
                heading: "Meal",
                title: mealTitle,
                detail: mealDetail
            )
        }
    }
    
    var amountLink: some View {
        NavigationLink {
            amountForm
        } label: {
            buttonLabel(
                heading: "Amount",
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
