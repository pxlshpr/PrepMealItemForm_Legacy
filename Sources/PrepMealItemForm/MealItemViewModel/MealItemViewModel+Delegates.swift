import PrepViews

extension MealItemViewModel: NutritionSummaryProvider {
    
    var forMeal: Bool {
        false
    }
    
    var isMarkedAsCompleted: Bool {
        false
    }
    
    var showQuantityAsSummaryDetail: Bool {
        false
    }
    
    var energyAmount: Double {
        234
    }
    
    var carbAmount: Double {
        56
    }
    
    var fatAmount: Double {
        38
    }
    
    var proteinAmount: Double {
        25
    }
}
