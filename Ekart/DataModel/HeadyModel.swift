//
//  Model.swift
//  Ekart
//
//  Created by Aniket on 9/21/19.
//  Copyright © 2019 Heady. All rights reserved.
//

import Foundation

enum RankingType: Int {
    case none = 0, orders = 1, views = 2, share = 3
}

// MARK: - Welcome
struct HeadyModel: Codable {
    let categories: [Category]
    let rankings: [Ranking]
}

// MARK: - Category
struct Category: Codable {
    let id: Int
    let name: String
    let products: [CategoryProduct]
    let childCategories: [Int]
    
    enum CodingKeys: String, CodingKey {
        case id, name, products
        case childCategories = "child_categories"
    }
}

// MARK: - CategoryProduct
class CategoryProduct: Codable {
    let id: Int
    let name, dateAdded: String
    let variants: [Variant]
    let tax: Tax
    var viewCount, orderCount, shares: Int?
    var rankCount: Int = -1
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case dateAdded = "date_added"
        case variants, tax
    }
}

// MARK: - CategoriesDetail
class CategoryDetail {
    let id: Int
    let name: String
    let hasChild: Bool
    var isOpen: Bool
    var level: Int
    
    init(id: Int, name: String, hasChild: Bool, isOpen: Bool, level: Int = 0) {
        self.id = id
        self.name = name
        self.hasChild = hasChild
        self.isOpen = isOpen
        self.level = level
    }
}

// MARK: - Tax
struct Tax: Codable {
    let name: String
    let value: Double
}

// MARK: - Variant
struct Variant: Codable {
    let id: Int
    let color: String
    let size: Int?
    let price: Int
}

// MARK: - Ranking
struct Ranking: Codable {
    let ranking: String
    let products: [RankingProduct]
}

//// MARK: - RankingProduct
struct RankingProduct: Codable {
    let id: Int
    let viewCount, orderCount, shares: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case viewCount = "view_count"
        case orderCount = "order_count"
        case shares
    }
}
