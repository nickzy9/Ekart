//
//  Model.swift
//  Ekart
//
//  Created by Aniket on 9/21/19.
//  Copyright © 2019 Heady. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct HeadyModel: Codable {
    let categories: [Category]
    let rankings: [Ranking]
}

// MARK: - Category
class Category: Codable {
    let id: Int
    let name: String
    let products: [CategoryProduct]
    let childCategories: [Int]
    var isOpen: Bool?
    var childCategoriesDetail: [ChildCategoriesDetail]?
    
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
    var rankCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case dateAdded = "date_added"
        case variants, tax
    }
}

// MARK: - ChildCategoriesDetail
struct ChildCategoriesDetail: Codable {
    let id: Int
    let name: String
}

// MARK: - Tax
struct Tax: Codable {
    let name: Name
    let value: Double
}

enum Name: String, Codable {
    case vat = "VAT"
    case vat4 = "VAT4"
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

// MARK: - RankingProduct
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
