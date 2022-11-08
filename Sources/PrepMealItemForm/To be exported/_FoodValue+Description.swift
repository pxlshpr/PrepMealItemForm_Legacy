//import PrepDataTypes
//
//public extension FoodValue {
//    func unitDescription(sizes: [FoodSize]) -> String {
//        switch self.unitType {
//        case .serving:
//            return "serving"
//        case .weight:
//            guard let weightUnit else {
//                return "invalid weight"
//            }
//            return weightUnit.shortDescription
//        case .volume:
//            guard let volumeUnit = volumeExplicitUnit?.volumeUnit else {
//                return "invalid volume"
//            }
//            return volumeUnit.shortDescription
//        case .size:
//            guard let size = sizes.sizeMatchingUnitSizeInFoodValue(self) else {
//                return "invalid size"
//            }
//            if let volumePrefixUnit = size.volumePrefixExplicitUnit?.volumeUnit {
//                return "\(volumePrefixUnit.shortDescription) \(size.name)"
//            } else {
//                return size.name
//            }
//        }
//    }
//}
//
