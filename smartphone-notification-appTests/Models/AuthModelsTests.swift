//
//  AuthModelsTests.swift
//  smartphone-notification-appTests
//
//  Created by sora.sakamoto on 2026/07/18.
//

import Testing
import Foundation
@testable import smartphone_notification_app

struct AuthModelsTests {

    @Test func loginRequestEncodesUsernameAndPassword() async throws {
        let request = LoginRequest(username: "sora", password: "secret")

        let encoded = try JSONEncoder().encode(request)
        let object = try JSONSerialization.jsonObject(with: encoded) as? [String: Any]

        #expect(object?["username"] as? String == "sora")
        #expect(object?["password"] as? String == "secret")
    }

    @Test func userDecodesFromAPIResponse() async throws {
        let json = """
        { "id": 1, "username": "sora" }
        """.data(using: .utf8)!

        let user = try JSONDecoder().decode(User.self, from: json)

        #expect(user.id == 1)
        #expect(user.username == "sora")
    }

    @Test func errorResponseDecodesWhenDetailIsPresent() async throws {
        let json = """
        { "detail": "invalid credentials" }
        """.data(using: .utf8)!

        let error = try JSONDecoder().decode(ErrorResponse.self, from: json)

        #expect(error.detail == "invalid credentials")
    }

    @Test func errorResponseDecodesWhenDetailIsMissing() async throws {
        let json = "{}".data(using: .utf8)!

        let error = try JSONDecoder().decode(ErrorResponse.self, from: json)

        #expect(error.detail == nil)
    }
}
