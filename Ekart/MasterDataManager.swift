//
//  MasterDataManager.swift
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
                categoriesData = unwrappedModel.categories
                rankingData = unwrappedModel.rankings
                updateProductListWithRankingData()
                prepareDisplayCategories()
            } else {
                categoriesData = []
                rankingData = []
            }
        }
    }
    
    var displayCategories = [CategoryDetail]()
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
    
    func removeAllChildCategories(id: Int) -> [Int] {
        guard let currentIndex = displayCategories.firstIndex(where: {($0.id == id)}) else { return [] }
        guard let mainCategory = displayCategories[safe: currentIndex] else { return [] }
        var nextIndex = currentIndex
        var next = true
        var removedIndexs = [Int]()
        while next {
            guard let category = displayCategories[safe: currentIndex + 1] else {
                return removedIndexs
            }
            if category.level > mainCategory.level {
                nextIndex += 1
                displayCategories.remove(at: currentIndex + 1)
                removedIndexs.append(nextIndex)
                next = true
            } else {
                next = false
            }
        }
        return removedIndexs
    }
}

private extension MasterDataManager {
    func prepareDisplayCategories() {
        displayCategories.removeAll()
        for category in categoriesData {
            if !isChildCategoryOfSomeOne(id: category.id) {
                let tempCategory = CategoryDetail(id: category.id, name: category.name,
                                                  hasChild: category.childCategories.count > 0,
                                                  isOpen: false)
                displayCategories.append(tempCategory)
            }
        }
    }
    
    func isChildCategoryOfSomeOne(id: Int) -> Bool {
        for category in categoriesData {
            if category.childCategories.contains(id) {
                return true
            }
        }
        return false
    }
    
    func updateProductListWithRankingData() {
        let allProducts = categoriesData.flatMap{$0.products}
        for ranking in rankingData {
            let filterProductList = allProducts.filter{ p in
                ranking.products.contains(where: {$0.id == p.id})
            }
            let _ = filterProductList.map{ p -> CategoryProduct in
                if let pf = ranking.products.first(where: {$0.id == p.id}) {
                    if let count = pf.viewCount {
                        p.viewCount = count
                    }
                    
                    if let count = pf.shares {
                        p.shares = count
                    }
                    
                    if let count = pf.orderCount {
                        p.orderCount = count
                    }
                }
                return p
            }
        }
    }
}
