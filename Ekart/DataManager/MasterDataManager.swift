//
//  MasterDataManager.swift
//  Ekart
//
//  Created by Aniket on 9/21/19.
//  Copyright © 2019 Heady. All rights reserved.
//

import Foundation

/// Data Manager
final class MasterDataManager {
    
    static let instance = MasterDataManager()
    private var isFetching = false
    
    private var headyModel: HeadyModel! {
        didSet {
            if let unwrappedModel = headyModel {
                categoriesData = unwrappedModel.categories
                rankingData = unwrappedModel.rankings
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
    
    /// Call API to fetch the data
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
                NotificationCenter.default.post(name: .categoriesDidFailToRefresh, object: nil)
            }
            self.isFetching = false
        }
    }
    
    /// Remove categories from display list
    func removeAllChildCategoriesFromDisplayCategories(id: Int) -> [Int] {
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
    
    /// Get products by ranking
    ///
    /// - Parameters:
    ///   - typeIndex: Ranking type array index
    ///   - sortByAsc: Set true for ASC order
    /// - Returns: Category products
    func getProductsWithRankingCount(by typeIndex: Int = 0, sortByAsc: Bool = true) -> [CategoryProduct] {
        let allProducts = categoriesData.flatMap{$0.products}
        guard let rankingProducts = rankingData[safe: typeIndex]?.products else {
            return []
        }
        
        let filterProducts = allProducts.filter{ p in
            rankingProducts.contains(where: {$0.id == p.id})
        }
        
        var updatedProducts = filterProducts.map{ p -> CategoryProduct in
            if let pf = rankingProducts.first(where: {$0.id == p.id}) {
                if let count = pf.viewCount {
                    p.rankCount = count
                }
                
                if let count = pf.shares {
                    p.rankCount = count
                }
                
                if let count = pf.orderCount {
                    p.rankCount = count
                }
            }
            return p
        }
        updatedProducts = updatedProducts.filter({($0.rankCount != -1 )})
        if sortByAsc {
            updatedProducts = updatedProducts.sorted(by: { $0.rankCount > $1.rankCount })
        } else {
            updatedProducts = updatedProducts.sorted(by: { $0.rankCount > $1.rankCount })
        }
        return updatedProducts
    }
}

// MARK: - Prepare display categories data
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
}
