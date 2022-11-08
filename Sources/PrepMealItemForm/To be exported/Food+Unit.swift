import PrepDataTypes

extension Food {
    var canBeMeasuredInWeight: Bool {
        if info.density != nil {
            return true
        }
        
        if info.amount.isWeightBased(in: self) {
            return true
        }
        if let serving = info.serving, serving.isWeightBased(in: self) {
            return true
        }
        for size in formSizes {
            if size.isWeightBased {
                return true
            }
        }
        return false
    }
    
    var canBeMeasuredInVolume: Bool {
        if info.density != nil {
            return true
        }
        
        if info.amount.isVolumeBased(in: self) {
            return true
        }
        if let serving = info.serving, serving.isVolumeBased(in: self) {
            return true
        }
        for size in formSizes {
            if size.isVolumeBased {
                return true
            }
        }
        return false
    }
}
