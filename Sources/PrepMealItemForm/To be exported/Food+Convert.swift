import PrepDataTypes

extension Food {
    
    func convert(_ quantity: FoodQuantity, to unit: FormUnit) -> FoodQuantity? {
        let converted: Double?
        print("⚖️ Converting \(quantity) to \(unit.shortDescription)")
        switch quantity.unit {
        case .weight(let weightUnit):
            converted = weightUnit.convert(amount: quantity.amount, to: unit)
        case .volume(let volumeUnit):
            converted = nil
        case .serving:
            converted = convertServing(amount: quantity.amount, to: unit)
        case .size(let sizeUnit, let sizeVolumePrefix):
            converted = convertSize(sizeUnit, amount: quantity.amount, to: unit)
        }
        guard let converted else { return nil }
        return FoodQuantity(amount: converted, unit: unit, food: self)
    }
    
    func convertServing(amount: Double, to unit: FormUnit) -> Double? {
        guard let serving = info.serving,
              let servingUnit
        else {
            return nil
        }
        //TODO: Reuse servingWeight etc here
        let converted: Double?
        switch servingUnit {
        case .weight(let weightUnit):
            print("⚖️     Converting \(serving.value) \(weightUnit.shortDescription) to \(unit.shortDescription)")
            converted = weightUnit.convert(amount: serving.value, to: unit)
        case .volume(let volumeUnit):
            converted = nil
        case .size(let formSize, let volumeUnit):
            converted = nil
        case .serving:
            /// We shouldn't encounter this
            return nil
        }
        guard let converted else { return nil }
        return converted * amount
    }
    
    func convertSize(_ size: FormSize, amount: Double, to unit: FormUnit) -> Double? {
        switch unit {
        case .weight(let weightUnit):
//            guard let unitWeight =
            print("⚪️ Converting \(amount.cleanAmount) of \(size.name) to \(unit.shortDescription)")
            guard let unitWeightQuantity = size.unitWeightQuantity(in: self),
                  let unitWeightAmount = unitWeightQuantity.unit.weightUnit?.convert(amount: amount, to: unit)
            else {
                return nil
            }
            print("⚪️ - unitWeightQuantity was \(unitWeightQuantity.description)")
            print("⚪️ - unitWeightAmount for \(unit.shortDescription) was \(unitWeightAmount)")
            print("⚪️ ")
            return unitWeightAmount * unitWeightQuantity.amount
        case .volume(let volumeUnit):
            return nil
        case .size(let formSize, let volumeUnit):
            return nil
        case .serving:
            guard let unitServings = size.unitServings else { return nil }
            return unitServings * amount
        }
    }

    var servingUnit: FormUnit? {
        guard let serving = info.serving else { return nil }
        return FormUnit(foodValue: serving, in: self)
    }
    
    var servingWeightQuantity: FoodQuantity? {
        guard let serving = info.serving,
              let servingUnit
        else {
            return nil
        }
        switch servingUnit {
        case .weight(let weightUnit):
            return FoodQuantity(
                amount: serving.value,
                unit: .weight(weightUnit),
                food: self
            )
        case .size(let sizeUnit, let sizeVolumePrefix):
            guard let sizeUnitWeightQuantity = sizeUnit.unitWeightQuantity(in: self) else {
                return nil
            }
            return FoodQuantity(
                amount: sizeUnitWeightQuantity.amount * serving.value,
                unit: sizeUnitWeightQuantity.unit,
                food: self
            )
        default:
            return nil
        }
    }
}

extension FormSize {
    /**
     Returns how many servings this size represents, if applicable. Drills down to the base size if necessary.
     
     Basic case:
     - 3 x **balls** = 1 serving
        *This would imply that 1 ball is 1/3 servings*
     
     Hierarchical case:
     - 2 x **sleeves** = 16 balls
     - 3 x balls = 1 serving
        *This implies that 1 sleeve would be  2.5 servings*
     */
    var unitServings: Double? {
        guard isServingBased, let amount, let quantity else { return nil }
        if unit == .serving {
            return amount / quantity
        } else if case .size(let sizeUnit, let volumePrefixUnit) = unit {
            guard let unitServings = sizeUnit.unitServings else {
                return nil
            }
            return (unitServings * amount) / quantity

            //TODO: What do we do about the volumePrefixUnit
        } else {
            return nil
        }
    }
    
    /**
     Returns the quantity representing how much 1 of this size weights, if applicable. Drills down to the base size if necessary.
     */
    func unitWeightQuantity(in food: Food) -> FoodQuantity? {
        guard let amount, let quantity else { return nil }
        
        switch unit {
        case .weight(let weightUnit):
            return FoodQuantity(
                amount: (amount / quantity),
                unit: .weight(weightUnit),
                food: food
            )
            
        case .serving:
            guard let servingWeightQuantity = food.servingWeightQuantity else {
                return nil
            }

            return FoodQuantity(
                amount: (servingWeightQuantity.amount * amount) / quantity,
                unit: servingWeightQuantity.unit,
                food: food
            )

        case .size(let sizeUnit, let volumePrefixUnit):
            guard let unitWeightQuantity = sizeUnit.unitWeightQuantity(in: food) else {
                return nil
            }
            return FoodQuantity(
                amount: (unitWeightQuantity.amount * amount) / quantity,
                unit: unitWeightQuantity.unit,
                food: food
            )

            //TODO: What do we do about the volumePrefixUnit
        default:
            return nil
        }
    }
}

extension WeightUnit {
    func convert(amount: Double, to unit: FormUnit) -> Double? {
        switch unit {
        case .weight(let weightUnit):
            return convert(amount: amount, to: weightUnit)
        case .volume(let volumeUnit):
            return nil
        case .size(let formSize, let volumeUnit):
            return nil
        case .serving:
            return nil
        }
    }
    
    func convert(amount: Double, to otherWeightUnit: WeightUnit) -> Double {
        let grams = self.g * amount
        let otherGrams = otherWeightUnit.g
        return grams / otherGrams
    }
}
