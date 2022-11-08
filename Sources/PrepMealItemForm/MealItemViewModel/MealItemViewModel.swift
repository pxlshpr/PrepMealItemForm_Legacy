import SwiftUI
import PrepDataTypes

class MealItemViewModel: ObservableObject {
    @Published var food: Food
    @Published var dayMeals: [DayMeal]
    
    @Published var amount: Double? = 1
    @Published var unit: FormUnit = .serving

    @Published var meal: Meal? = nil
    
    init(food: Food, meal: Meal? = nil, dayMeals: [DayMeal]) {
        self.food = food
        self.meal = meal
        self.dayMeals = dayMeals
    }
    
    var timelineItems: [TimelineItem] {
        dayMeals.map { TimelineItem(dayMeal: $0) }
    }
    
    var amountTitle: String? {
        guard let amount else {
            return nil
        }
        return "\(amount.cleanAmount) \(unit.shortDescription)"
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
        let amount = self.amount ?? 0
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
    
    var amountHeaderString: String {
        unit.unitType.description
    }
}
