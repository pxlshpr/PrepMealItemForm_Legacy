import SwiftUI

struct FoodSearchConstants {
    
    /// ** Hardcoded and repeated **
    static let largeDeviceWidthCutoff: CGFloat = 850.0
    static let keyboardHeight: CGFloat = UIScreen.main.bounds.height < largeDeviceWidthCutoff
    ? 291
    : 301
}

