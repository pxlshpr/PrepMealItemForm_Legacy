import PrepDataTypes

extension FoodValue {

    func foodSizeUnit(in food: Food) -> FoodSize? {
        food.info.sizes.first(where: { $0.id == self.sizeUnitId })
    }
    
    func formSizeUnit(in food: Food) -> FormSize? {
        guard let foodSize = foodSizeUnit(in: food) else {
            return nil
        }
        return FormSize(foodSize: foodSize, in: food.info.sizes)
    }
    
    func isWeightBased(in food: Food) -> Bool {
        unitType == .weight || hasWeightBasedSizeUnit(in: food)
    }

    func isVolumeBased(in food: Food) -> Bool {
        unitType == .volume || hasVolumeBasedSizeUnit(in: food)
    }
    
    func hasVolumeBasedSizeUnit(in food: Food) -> Bool {
        formSizeUnit(in: food)?.isVolumeBased == true
    }
    
    func hasWeightBasedSizeUnit(in food: Food) -> Bool {
        formSizeUnit(in: food)?.isWeightBased == true
    }
}
