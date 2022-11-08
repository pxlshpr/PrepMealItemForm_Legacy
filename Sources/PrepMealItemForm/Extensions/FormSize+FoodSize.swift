import PrepDataTypes

public extension FormSize {
    init?(foodSize: FoodSize, in sizes: [FoodSize]) {
        let volumePrefixUnit: FormUnit?
        if let volumePrefixExplicitUnit = foodSize.volumePrefixExplicitUnit {
            guard let formUnit = FormUnit(volumeExplicitUnit: volumePrefixExplicitUnit) else {
                return nil
            }
            volumePrefixUnit = formUnit
        } else {
            volumePrefixUnit = nil
        }
        
        guard let unit = FormUnit(foodValue: foodSize.value, in: sizes) else {
            return nil
        }
        
        self.init(
            quantity: foodSize.quantity,
            volumePrefixUnit: volumePrefixUnit,
            name: foodSize.name,
            amount: foodSize.value.value,
            unit: unit
        )
    }
}
