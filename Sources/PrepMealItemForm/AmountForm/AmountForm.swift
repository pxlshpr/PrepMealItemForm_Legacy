import SwiftUI
import PrepDataTypes
import SwiftHaptics
import SwiftUISugar
import PrepViews
import Combine

extension MealItemForm {
    public struct AmountForm: View {
        
        @EnvironmentObject var viewModel: MealItemViewModel

        @Environment(\.colorScheme) var colorScheme
        @Environment(\.dismiss) var dismiss
        @Binding var isPresented: Bool
        
        @FocusState var isFocused: Bool
        @State var animatedIsFocused: Bool = false
        @State var showingUnitPicker = false
        
        public init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
        }
    }
}

public extension MealItemForm.AmountForm {

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
        .navigationTitle("Amount")
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
//            nutrientsSummarySection
//            goalIncrementSection
//            mealIncrementSection
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
