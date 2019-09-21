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
    private var isFetching = false
    
    private var headyModel: HeadyModel! {
        didSet {
            if let unwrappedModel = headyModel {
                categoriesData = getCategoriesWithChildDetails()
                rankingData = unwrappedModel.rankings
            } else {
                categoriesData = []
                rankingData = []
            }
        }
    }
    var categoriesData = [Category]()
    var rankingData = [Ranking]()
    
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
            
            self.headyModel = data
            
            switch resMsg {
            case .success:
                NotificationCenter.default.post(name: .categoriesDidUpdate, object: nil)
            default:
                NotificationCenter.default.post(name: .categoriesDidFailToRefresh, object: resMsg)
            }
            
            self.isFetching = false
        }
    }
    
    private func getCategoriesWithChildDetails()-> [Category] {
        let updatedCategories = headyModel.categories.map { cp -> Category in
            var tempChildCategories = [ChildCategoriesDetail]()
            for id in cp.childCategories {
                let category = headyModel.categories.first(where: {$0.id == id})
                let tempChildCategory = ChildCategoriesDetail(id: id, name: category?.name ?? "")
                tempChildCategories.append(tempChildCategory)
            }
            cp.childCategoriesDetail = tempChildCategories
            return cp
        }
        
        return updatedCategories
    }
}
