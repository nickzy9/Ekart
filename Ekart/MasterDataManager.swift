//
//  CategoriesManager.swift
//  Ekart
//
//  Created by Aniket on 9/21/19.
//  Copyright © 2019 Heady. All rights reserved.
//

import Foundation

final class MasterDataManager {
    
    static let instance = MasterDataManager()
    var categoriesData = [Category]()
    var rankingData = [Ranking]()
    var isFetching = false
    
    func fetch() {
        if isFetching { return }
        isFetching = true
        
        NotificationCenter.default.post(name: .categoriesStartRefresh, object: nil)
        Service.shared.apiCall(Global.api.headyProducts, isToGetSavedData: true) { (data, resMsg) in
            
            guard let data = data as? HeadyModel else {
                self.isFetching = false
                NotificationCenter.default.post(name: .categoriesDidFailToRefresh, object: resMsg)
                return
            }
            
            switch resMsg {
            case .success:
                self.categoriesData = data.categories
                self.rankingData = data.rankings
                NotificationCenter.default.post(name: .categoriesDidUpdate, object: nil)
            default:
                self.categoriesData = data.categories
                self.rankingData = data.rankings
                NotificationCenter.default.post(name: .categoriesDidFailToRefresh, object: resMsg)
            }
            
            self.isFetching = false
        }
    }
}
