import PrepDataTypes

public extension Food {
    var formSizes: [FormSize] {
        info.sizes.compactMap { foodSize in
            FormSize(foodSize: foodSize, in: info.sizes)
        }
    }
    
    var servingDescription: String? {
        guard let serving = info.serving else { return nil }
        return "\(serving.value.cleanAmount) \(serving.unitDescription(sizes: info.sizes))"
    }
}
