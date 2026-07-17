//
//  Subcategory.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import Foundation

// サブカテゴリのデータ構造
struct Subcategory: Codable, Identifiable {
    let id: Int
    let name: String
    let categoryId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case categoryId = "category_id"
    }
}
