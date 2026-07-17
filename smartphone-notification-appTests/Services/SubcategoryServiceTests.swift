//
//  SubcategoryServiceTests.swift
//  smartphone-notification-appTests
//
//  Created by sora.sakamoto on 2026/07/18.
//

import Testing
import Foundation
@testable import smartphone_notification_app

@MainActor
struct SubcategoryServiceTests {

    @Test func fetchSubcategoriesDecodesSuccessfulResponse() async throws {
        let json = #"[{"id": 1, "name": "二次関数", "category_id": 10}]"#
        let session = MockURLProtocol.makeSession(json: json)
        let service = SubcategoryService(session: session)

        await service.fetchSubcategories(byCategoryId: 10)

        #expect(service.subcategories.count == 1)
        #expect(service.subcategories.first?.name == "二次関数")
        #expect(service.errorMessage == nil)
    }

    @Test func fetchSubcategoriesIncludesSearchWordInRequestURL() async throws {
        var capturedURL: URL?
        let session = MockURLProtocol.makeSession { request in
            capturedURL = request.url
            return (200, "[]".data(using: .utf8)!)
        }
        let service = SubcategoryService(session: session)

        await service.fetchSubcategories(byCategoryId: 10, searchWord: "関数")

        let queryValue = capturedURL.flatMap {
            URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "searchSubcategoryName" })?.value
        }
        #expect(queryValue == "関数")
    }

    @Test func fetchSubcategoriesSetsErrorMessageOnServerError() async throws {
        let session = MockURLProtocol.makeSession(statusCode: 500, data: Data())
        let service = SubcategoryService(session: session)

        await service.fetchSubcategories(byCategoryId: 10)

        #expect(service.subcategories.isEmpty)
        #expect(service.errorMessage != nil)
    }

    @Test func fetchSubcategoriesSetsErrorMessageOnMalformedData() async throws {
        let session = MockURLProtocol.makeSession(json: #"{"not":"an array"}"#)
        let service = SubcategoryService(session: session)

        await service.fetchSubcategories(byCategoryId: 10)

        #expect(service.subcategories.isEmpty)
        #expect(service.errorMessage != nil)
    }
}
