//
//  AuthServiceTests.swift
//  smartphone-notification-appTests
//
//  Created by sora.sakamoto on 2026/07/18.
//

import Testing
import Foundation
@testable import smartphone_notification_app

@MainActor
struct AuthServiceTests {

    @Test func loginSucceedsAndFetchesCurrentUser() async throws {
        let session = MockURLProtocol.makeSession { request in
            if request.url?.path.hasSuffix("/login") == true {
                return (200, Data())
            }
            let json = #"{"id": 1, "username": "sora"}"#
            return (200, json.data(using: .utf8)!)
        }
        let service = AuthService(session: session)

        let success = await service.login(username: "sora", password: "secret")

        #expect(success)
        #expect(service.isAuthenticated)
        #expect(service.currentUser?.username == "sora")
    }

    @Test func loginFailureSurfacesServerErrorDetail() async throws {
        let session = MockURLProtocol.makeSession { request in
            if request.url?.path.hasSuffix("/login") == true {
                let json = #"{"detail": "ユーザー名またはパスワードが違います"}"#
                return (401, json.data(using: .utf8)!)
            }
            return (401, Data())
        }
        let service = AuthService(session: session)

        let success = await service.login(username: "sora", password: "wrong")

        #expect(!success)
        #expect(service.errorMessage == "ユーザー名またはパスワードが違います")
        #expect(!service.isAuthenticated)
    }

    @Test func checkAuthSetsUnauthenticatedOnNon200Response() async throws {
        let session = MockURLProtocol.makeSession { _ in (401, Data()) }
        let service = AuthService(session: session)

        await service.checkAuth()

        #expect(!service.isAuthenticated)
        #expect(service.currentUser == nil)
    }

    @Test func logoutClearsAuthenticatedState() async throws {
        let session = MockURLProtocol.makeSession { request in
            if request.url?.path.hasSuffix("/me") == true {
                let json = #"{"id": 1, "username": "sora"}"#
                return (200, json.data(using: .utf8)!)
            }
            return (200, Data())
        }
        let service = AuthService(session: session)
        await service.checkAuth()
        #expect(service.isAuthenticated)

        await service.logout()

        #expect(!service.isAuthenticated)
        #expect(service.currentUser == nil)
    }
}
