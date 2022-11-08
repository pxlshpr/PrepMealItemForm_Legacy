import PrepDataTypes

struct FormQuantity {
    let amount: Double
    let unit: FormUnit
}

extension FormQuantity: CustomStringConvertible {
    var description: String {
        "\(amount.cleanAmount) \(unit.shortDescription)"
    }
}
