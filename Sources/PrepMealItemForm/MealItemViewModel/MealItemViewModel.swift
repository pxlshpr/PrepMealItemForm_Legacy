import SwiftUI
import PrepDataTypes

class MealItemViewModel: ObservableObject {
    @Published var food: Food
    @Published var dayMeals: [DayMeal]
    
    @Published var unit: FormUnit = .serving

    @Published var internalAmountDouble: Double?
    @Published var internalAmountString: String = ""

    @Published var meal: Meal? = nil
    
    var amount: Double? {
        get {
            return internalAmountDouble
        }
        set {
            internalAmountDouble = newValue
            internalAmountString = newValue?.cleanAmount ?? ""
        }
    }
    
    var amountString: String {
        get {
            return internalAmountString
        }
        set {
            guard !newValue.isEmpty else {
                internalAmountDouble = nil
                internalAmountString = newValue
                return
            }
            guard let double = Double(newValue) else {
                return
            }
            self.internalAmountDouble = double
            self.internalAmountString = newValue
        }
    }
    
    init(food: Food, meal: Meal? = nil, dayMeals: [DayMeal]) {
        self.food = food
        self.meal = meal
        self.dayMeals = dayMeals
    }
    
    var timelineItems: [TimelineItem] {
        dayMeals.map { TimelineItem(dayMeal: $0) }
    }
    
    var amountTitle: String? {
        guard let internalAmountDouble else {
            return nil
        }
        return "\(internalAmountDouble.cleanAmount) \(unit.shortDescription)"
    }
    
    var amountDetail: String? {
        //TODO: Get the primary equivalent value here
        ""
    }
    
    var saveButtonTitle: String {
        guard let meal else {
            return "Prep"
        }
        return meal.day.date < Date() ? "Log" : "Prep"
    }
    
    func stepAmount(by step: Int) {
        let amount = self.amount ?? 0
        self.amount = amount + Double(step)
    }
    
    func amountCanBeStepped(by step: Int) -> Bool {
        let amount = self.internalAmountDouble ?? 0
        return amount + Double(step) > 0
    }
    
    var unitDescription: String {
        unit.shortDescription
    }
    
    var shouldShowServingInUnitPicker: Bool {
        food.info.serving != nil
    }
    
    var foodSizes: [FormSize] {
        food.formSizes
    }
    
    var servingDescription: String? {
        food.servingDescription
    }
    
    func didPickUnit(_ unit: FormUnit) {
        self.unit = unit
    }
    
    func didPickQuantity(_ quantity: FormQuantity) {
        self.amount = quantity.amount
        self.unit = quantity.unit
    }
    var amountHeaderString: String {
        unit.unitType.description
    }
}

extension MealItemViewModel {
    var equivalentQuantities: [FormQuantity]? {
        guard let currentQuantity else { return nil }
        
        return food
            .possibleUnits(without: unit)
            .compactMap { food.convert(currentQuantity, to: $0) }
    }
    
    var currentQuantity: FormQuantity? {
        guard let internalAmountDouble else { return nil }
        return FormQuantity(amount: internalAmountDouble, unit: unit)
    }    
}
