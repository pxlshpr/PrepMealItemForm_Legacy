import SwiftUI
import PrepDataTypes
import PrepCoreDataStack
import PrepMocks
import PrepViews

public enum MealItemFormRoute {
    case mealItemForm
    case food
    case meal
}

public class MealItemViewModel: ObservableObject {
    
    @Published var path: [MealItemFormRoute] = []

    @Published var food: Food?
    @Published var dayMeals: [DayMeal]
    
    @Published var unit: FoodQuantity.Unit = .serving

    @Published var internalAmountDouble: Double? = 1
    @Published var internalAmountString: String = "1"

//    @Published var meal: Meal? = nil
    @Published var meal: Meal? = nil
    @Published var dayMeal: DayMeal? = nil

    @Published var day: Day? = nil

    @Published var mealFoodItem: MealFoodItem
    
    public init(food: Food? = nil, day: Day? = nil, meal: Meal? = nil, dayMeals: [DayMeal] = []) {
        self.day = day
        self.food = food
        self.meal = meal
        self.dayMeals = dayMeals
        
        if let meal {
            self.dayMeal = DayMeal(from: meal)
        }
        //TODO: Handle this in a better way
        /// [ ] Try making `mealFoodItem` nil and set it as that if we don't get a food here
        /// [ ] Try and get this fed in with an existing `FoodItem`, from which we create this when editing!
        self.mealFoodItem = MealFoodItem(
            food: food ?? FoodMock.peanutButter,
            amount: .init(0, .g)
        )

        NotificationCenter.default.addObserver(self, selector: #selector(didPickMeal), name: .didPickMeal, object: nil)        
    }
    
    @objc func didPickMeal(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let dayMeal = userInfo[Notification.Keys.meal] as? DayMeal
        else { return }
        
        self.dayMeal = dayMeal
    }

    func setFood(_ food: Food) {
        self.food = food
        setDefaultUnit()
        setFoodItem()
    }
    
    func setDefaultUnit() {
        //TODO: First see if we have a last-used unit and amount for this and use that
        /// Something like: `guard let lastUsedQuantity = DataManager.shared.lastUsedQuantity(for: food)`
        
        guard let amountQuantity = food?.defaultQuantity else {
            return
        }
        self.amount = amountQuantity.value
        self.unit = amountQuantity.unit
    }
    
    var amount: Double? {
        get {
            return internalAmountDouble
        }
        set {
            internalAmountDouble = newValue
            internalAmountString = newValue?.cleanAmount ?? ""
            setFoodItem()
        }
    }
    
    func setFoodItem() {
        guard let food else { return }
        self.mealFoodItem = MealFoodItem(
            food: food,
            amount: amountValue
        )
    }
    
    var amountString: String {
        get {
            return internalAmountString
        }
        set {
            guard !newValue.isEmpty else {
                internalAmountDouble = nil
                internalAmountString = newValue
                setFoodItem()
                return
            }
            guard let double = Double(newValue) else {
                return
            }
            self.internalAmountDouble = double
            self.internalAmountString = newValue
            setFoodItem()
        }
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
        guard let food else { return false }
        return food.info.serving != nil
    }
    
    var foodSizes: [FormSize] {
        food?.formSizes ?? []
    }
    
    var servingDescription: String? {
        food?.servingDescription(using: DataManager.shared.userVolumeUnits)
    }
    
    func didPickUnit(_ formUnit: FormUnit) {
        guard
            let food,
            let unit = FoodQuantity.Unit(
                formUnit: formUnit,
                food: food,
                userVolumeUnits: DataManager.shared.userVolumeUnits
            )
        else { return }
        
        self.unit = unit
        setFoodItem()
    }
    
    func didPickQuantity(_ quantity: FoodQuantity) {
        self.amount = quantity.value
        self.unit = quantity.unit
    }
    var amountHeaderString: String {
        unit.unitType.description
    }
    
    var shouldShowWeightUnits: Bool {
        food?.canBeMeasuredInWeight ?? false
    }
    
    var shouldShowVolumeUnits: Bool {
        food?.canBeMeasuredInVolume ?? false
    }
    
    var amountValue: FoodValue {
        FoodValue(
            value: amount ?? 0,
            foodQuantityUnit: unit,
            userUnits: DataManager.shared.user?.units ?? .standard
        )
    }
    
//    var foodItemBinding: Binding<MealFoodItem> {
//        Binding<MealFoodItem>(
//            get: {
//                print("Getting MealFoodItem")
//                return MealFoodItem(
//                    food: self.food,
//                    amount: self.amountValue
//                )
//            },
//            set: { _ in }
//        )
//    }
//
//    var dayMeal: DayMeal? {
//        guard let meal else { return nil }
//        return DayMeal(from: meal)
//    }
}

extension FoodValue {
    init(
        value: Double,
        foodQuantityUnit unit: FoodQuantity.Unit,
        userUnits: UserUnits
    ) {
        
        let volumeExplicitUnit: VolumeExplicitUnit?
        if let volumeUnit = unit.formUnit.volumeUnit {
            volumeExplicitUnit = userUnits.volume.volumeExplicitUnit(for: volumeUnit)
        } else {
            volumeExplicitUnit = nil
        }

        let sizeUnitVolumePrefixExplicitUnit: VolumeExplicitUnit?
        if let volumeUnit = unit.formUnit.sizeUnitVolumePrefixUnit {
            sizeUnitVolumePrefixExplicitUnit = userUnits.volume.volumeExplicitUnit(for: volumeUnit)
        } else {
            sizeUnitVolumePrefixExplicitUnit = nil
        }

        self.init(
            value: value,
            unitType: unit.unitType,
            weightUnit: unit.formUnit.weightUnit,
            volumeExplicitUnit: volumeExplicitUnit,
            sizeUnitId: unit.formUnit.size?.id,
            sizeUnitVolumePrefixExplicitUnit: sizeUnitVolumePrefixExplicitUnit
        )
    }
}

extension MealItemViewModel {
    var equivalentQuantities: [FoodQuantity] {
        guard let currentQuantity else { return [] }
        let quantities = currentQuantity.equivalentQuantities(using: DataManager.shared.userVolumeUnits)
        return quantities
    }
    
    var currentQuantity: FoodQuantity? {
        guard
            let food,
            let internalAmountDouble
        else { return nil }
        
        return FoodQuantity(
            value: internalAmountDouble,
            unit: unit,
            food: food
        )
    }    
}

extension MealItemViewModel: NutritionSummaryProvider {
    public var forMeal: Bool {
        false
    }
    
    public var isMarkedAsCompleted: Bool {
        false
    }
    
    public var showQuantityAsSummaryDetail: Bool {
        false
    }
    
    public var energyAmount: Double {
        mealFoodItem.scaledValue(for: .energy)
    }
    
    public var carbAmount: Double {
        mealFoodItem.scaledValue(for: .carb)
    }
    
    public var fatAmount: Double {
        mealFoodItem.scaledValue(for: .fat)
    }
    
    public var proteinAmount: Double {
        mealFoodItem.scaledValue(for: .protein)
    }
}
