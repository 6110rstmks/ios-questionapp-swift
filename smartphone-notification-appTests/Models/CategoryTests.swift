//
//  CategoryTests.swift
//  smartphone-notification-appTests
//
//  Created by sora.sakamoto on 2026/07/18.
//

import Testing
import Foundation
@testable import smartphone_notification_app

struct CategoryTests {

    @Test func decodesSnakeCaseFieldsFromAPI() async throws {
        let json = """
        {
            "id": 1,
            "name": "数学",
            "user_id": 42,
            "is_blacklisted": false,
            "is_public": true,
            "question_count": 10,
            "incorrected_answered_question_count": 3
        }
        """.data(using: .utf8)!

        let category = try JSONDecoder().decode(Category.self, from: json)

        #expect(category.id == 1)
        #expect(category.name == "数学")
        #expect(category.userId == 42)
        #expect(category.isBlackListed == false)
        #expect(category.isPublic == true)
        #expect(category.questionCount == 10)
        #expect(category.incorrectedAnsweredQuestionCount == 3)
    }

    @Test func encodesBackToSnakeCaseKeys() async throws {
        let category = Category(
            id: 5,
            name: "英語",
            userId: 7,
            isBlackListed: true,
            isPublic: false,
            questionCount: 2,
            incorrectedAnsweredQuestionCount: 1
        )

        let encoded = try JSONEncoder().encode(category)
        let object = try JSONSerialization.jsonObject(with: encoded) as? [String: Any]

        #expect(object?["user_id"] as? Int == 7)
        #expect(object?["is_blacklisted"] as? Bool == true)
        #expect(object?["is_public"] as? Bool == false)
        #expect(object?["question_count"] as? Int == 2)
        #expect(object?["incorrected_answered_question_count"] as? Int == 1)
    }
}
