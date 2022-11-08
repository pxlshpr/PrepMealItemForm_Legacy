//import PrepDataTypes
//
//extension FoodQuantity {
//
//    func convert(to toFormUnit: FormUnit) -> FoodQuantity? {
//        let converted: Double?
//        print("⚖️ Converting \(self) to \(toFormUnit.shortDescription)")
//        
//        switch self.unit {
//            
//        case .weight(let weightUnit):
//            converted = convertFromWeight(amount: amount, fromWeightUnit: weightUnit, toFormUnit: toFormUnit)
//            
//        case .volume(let volumeUnit):
//            converted = nil
//
//        case .serving:
//            converted = convertFromServings(amount: amount, toFormUnit: toFormUnit)
//
//        case .size(let sizeUnit, let sizeVolumePrefix):
//            converted = convertSize(sizeUnit, amount: amount, toFormUnit: toFormUnit)
//            
//        }
//        
//        guard let converted else { return nil }
//        return FoodQuantity(
//            amount: converted,
//            unit: toFormUnit,
//            food: self.food
//        )
//    }
//    
//    func convertFromWeight(amount: Double, fromWeightUnit: WeightUnit, toFormUnit: FormUnit) -> Double? {
//        switch toFormUnit {
//            
//        case .weight(let weightUnit):
//            return fromWeightUnit.convert(amount: amount, to: weightUnit)
//            
//        case .volume(let volumeUnit):
//            return nil
//            
//        case .size(let formSize, let volumeUnit):
//            return nil
//            
//        //MARK: Weight → Serving
//            /// 60g -> x servings
//        case .serving:
//            guard let servingWeightQuantity = food.servingWeightQuantity,
//                  let servingWeightUnit = servingWeightQuantity.unit.weightUnit
//            else {
//                return nil
//            }
//            
//            let converted = servingWeightUnit.convert(
//                amount: servingWeightQuantity.amount,
//                to: fromWeightUnit
//            )
//            guard amount > 0 else { return nil }
//            
//            return amount / converted
//        }
//    }
//    
//    func convertFromServings(amount: Double, toFormUnit: FormUnit) -> Double? {
//        guard let serving = food.info.serving, let servingUnit = food.servingUnit else {
//            return nil
//        }
//        //TODO: Reuse servingWeight etc here
//        let converted: Double?
//        switch servingUnit {
//                    
//        case .weight(let weightUnit):
//            converted = convertFromWeight(
//                amount: serving.value,
//                fromWeightUnit: weightUnit,
//                toFormUnit: toFormUnit
//            )
//            
//        case .volume(let volumeUnit):
//            converted = nil
//            
//        case .size(let formSize, let volumeUnit):
//            converted = nil
//            
//        case .serving:
//            /// We shouldn't encounter this
//            return nil
//        }
//        guard let converted else { return nil }
//        return converted * amount
//    }
//    
//    func convertSize(
//        _ size: FormSize,
//        amount: Double,
//        toFormUnit: FormUnit
//    ) -> Double? {
//        
//        switch toFormUnit {
//        
//        case .weight:
//            //MARK: Size → Weight
//            guard
//                let unitWeightQuantity = size.unitWeightQuantity(in: food),
//                let fromWeightUnit = unitWeightQuantity.unit.weightUnit,
//                let unitWeightAmount = convertFromWeight(
//                    amount: amount,
//                    fromWeightUnit: fromWeightUnit,
//                    toFormUnit: toFormUnit)
//            else {
//                return nil
//            }
//            return unitWeightAmount * unitWeightQuantity.amount
//        case .volume(let volumeUnit):
//            return nil
//        case .size(let formSize, let volumeUnit):
//            return nil
//        case .serving:
//            guard let unitServings = size.unitServings else { return nil }
//            return unitServings * amount
//        }
//    }
//
//}
//
//extension Food {
//
//    var servingUnit: FormUnit? {
//        guard let serving = info.serving else { return nil }
//        return FormUnit(foodValue: serving, in: self)
//    }
//    
//    var servingWeightQuantity: FoodQuantity? {
//        guard let serving = info.serving,
//              let servingUnit
//        else {
//            return nil
//        }
//        switch servingUnit {
//        case .weight(let weightUnit):
//            return FoodQuantity(
//                amount: serving.value,
//                unit: .weight(weightUnit),
//                food: self
//            )
//        case .size(let sizeUnit, let sizeVolumePrefix):
//            guard let sizeUnitWeightQuantity = sizeUnit.unitWeightQuantity(in: self) else {
//                return nil
//            }
//            return FoodQuantity(
//                amount: sizeUnitWeightQuantity.amount * serving.value,
//                unit: sizeUnitWeightQuantity.unit,
//                food: self
//            )
//        default:
//            return nil
//        }
//    }
//}
//
//extension FormSize {
//    /**
//     Returns how many servings this size represents, if applicable. Drills down to the base size if necessary.
//     
//     Basic case:
//     - 3 x **balls** = 1 serving
//        *This would imply that 1 ball is 1/3 servings*
//     
//     Hierarchical case:
//     - 2 x **sleeves** = 16 balls
//     - 3 x balls = 1 serving
//        *This implies that 1 sleeve would be  2.5 servings*
//     */
//    var unitServings: Double? {
//        guard isServingBased, let amount, let quantity else { return nil }
//        if unit == .serving {
//            return amount / quantity
//        } else if case .size(let sizeUnit, let volumePrefixUnit) = unit {
//            guard let unitServings = sizeUnit.unitServings else {
//                return nil
//            }
//            return (unitServings * amount) / quantity
//
//            //TODO: What do we do about the volumePrefixUnit
//        } else {
//            return nil
//        }
//    }
//    
//    /**
//     Returns the quantity representing how much 1 of this size weights, if applicable. Drills down to the base size if necessary.
//     */
//    func unitWeightQuantity(in food: Food) -> FoodQuantity? {
//        guard let amount, let quantity else { return nil }
//        
//        switch unit {
//        case .weight(let weightUnit):
//            return FoodQuantity(
//                amount: (amount / quantity),
//                unit: .weight(weightUnit),
//                food: food
//            )
//            
//        case .serving:
//            guard let servingWeightQuantity = food.servingWeightQuantity else {
//                return nil
//            }
//
//            return FoodQuantity(
//                amount: (servingWeightQuantity.amount * amount) / quantity,
//                unit: servingWeightQuantity.unit,
//                food: food
//            )
//
//        case .size(let sizeUnit, let volumePrefixUnit):
//            guard let unitWeightQuantity = sizeUnit.unitWeightQuantity(in: food) else {
//                return nil
//            }
//            return FoodQuantity(
//                amount: (unitWeightQuantity.amount * amount) / quantity,
//                unit: unitWeightQuantity.unit,
//                food: food
//            )
//
//            //TODO: What do we do about the volumePrefixUnit
//        default:
//            return nil
//        }
//    }
//}
//
//extension WeightUnit {
//    func convert(amount: Double, to otherWeightUnit: WeightUnit) -> Double {
//        let grams = self.g * amount
//        let otherGrams = otherWeightUnit.g
//        return grams / otherGrams
//    }
//}
