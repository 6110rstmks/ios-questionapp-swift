//
//  SubcategoryTests.swift
//  smartphone-notification-appTests
//
//  Created by sora.sakamoto on 2026/07/18.
//

import Testing
import Foundation
@testable import smartphone_notification_app

struct SubcategoryTests {

    @Test func decodesSnakeCaseFieldsFromAPI() async throws {
        let json = """
        {
            "id": 3,
            "name": "二次関数",
            "category_id": 1
        }
        """.data(using: .utf8)!

        let subcategory = try JSONDecoder().decode(Subcategory.self, from: json)

        #expect(subcategory.id == 3)
        #expect(subcategory.name == "二次関数")
        #expect(subcategory.categoryId == 1)
    }

    @Test func encodesBackToSnakeCaseKeys() async throws {
        let subcategory = Subcategory(id: 9, name: "文法", categoryId: 4)

        let encoded = try JSONEncoder().encode(subcategory)
        let object = try JSONSerialization.jsonObject(with: encoded) as? [String: Any]

        #expect(object?["category_id"] as? Int == 4)
    }
}
