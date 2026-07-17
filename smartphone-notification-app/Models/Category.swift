//
//  Category.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import Foundation

// APIから返ってくるカテゴリのデータ構造
struct Category: Codable, Identifiable {
    let id: Int
    let name: String
    let userId: Int
    let isBlackListed: Bool
    let isPublic: Bool
    let questionCount: Int
    let incorrectedAnsweredQuestionCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case userId = "user_id"
        case isBlackListed = "is_blacklisted"
        case isPublic = "is_public"
        case questionCount = "question_count"
        case incorrectedAnsweredQuestionCount = "incorrected_answered_question_count"
    }
}
