//import PrepDataTypes
//
//extension Food {
//    
//    func possibleUnits(without unit: FormUnit) -> [FormUnit] {
//        possibleUnits.filter { $0 != unit }
//    }
//    
//    var possibleUnits: [FormUnit] {
//        var units: [FormUnit] = []
//        for formSize in formSizes {
//            units.append(.size(formSize, nil))
//        }
//        if info.serving != nil {
//            units.append(.serving)
//        }
//        if canBeMeasuredInWeight {
//            units.append(.weight(.g))
//            units.append(.weight(.oz))
//        }
//        if canBeMeasuredInVolume {
//            units.append(.volume(.mL))
//            units.append(.volume(.fluidOunce))
//            units.append(.volume(.cup))
//            units.append(.volume(.tablespoon))
//            units.append(.volume(.teaspoon))
//        }
//        return units
//    }    
//}
