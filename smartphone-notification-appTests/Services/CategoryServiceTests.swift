//
//  CategoryServiceTests.swift
//  smartphone-notification-appTests
//
//  Created by sora.sakamoto on 2026/07/18.
//

import Testing
import Foundation
@testable import smartphone_notification_app

@MainActor
struct CategoryServiceTests {

    private func categoryJSON(idsStartingAt start: Int, count: Int) -> Data {
        let items = (start..<(start + count)).map {
            #"{"id": \#($0), "name": "category-\#($0)", "user_id": 1}"#
        }
        return "[\(items.joined(separator: ","))]".data(using: .utf8)!
    }

    private func skip(from request: URLRequest) -> Int {
        guard
            let url = request.url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let skipItem = components.queryItems?.first(where: { $0.name == "skip" }),
            let value = skipItem.value,
            let skip = Int(value)
        else {
            return 0
        }
        return skip
    }

    @Test func fetchCategoriesLoadsFirstFullPage() async throws {
        let session = MockURLProtocol.makeSession { _ in
            (200, self.categoryJSON(idsStartingAt: 0, count: 20))
        }
        let service = CategoryService(session: session)

        await service.fetchCategories()

        #expect(service.categories.count == 20)
        #expect(service.hasMoreData)
        #expect(service.errorMessage == nil)
    }

    @Test func loadMoreCategoriesAppendsAndStopsWhenPageIsPartial() async throws {
        let session = MockURLProtocol.makeSession { request in
            let skip = self.skip(from: request)
            if skip == 0 {
                return (200, self.categoryJSON(idsStartingAt: 0, count: 20))
            } else {
                return (200, self.categoryJSON(idsStartingAt: 20, count: 5))
            }
        }
        let service = CategoryService(session: session)

        await service.fetchCategories()
        #expect(service.hasMoreData)

        await service.loadMoreCategories()

        #expect(service.categories.count == 25)
        #expect(!service.hasMoreData)

        // hasMoreData が false になった後は追加取得しない
        await service.loadMoreCategories()
        #expect(service.categories.count == 25)
    }

    @Test func loadMoreCategoriesStopsWhenPageIsEmpty() async throws {
        let session = MockURLProtocol.makeSession { _ in (200, "[]".data(using: .utf8)!) }
        let service = CategoryService(session: session)

        await service.fetchCategories()

        #expect(service.categories.isEmpty)
        #expect(!service.hasMoreData)
    }

    @Test func fetchCategoriesSetsErrorMessageOnServerError() async throws {
        let session = MockURLProtocol.makeSession { _ in (500, Data()) }
        let service = CategoryService(session: session)

        await service.fetchCategories()

        #expect(service.categories.isEmpty)
        #expect(service.errorMessage != nil)
    }

    @Test func fetchCategoriesSetsErrorMessageOnMalformedData() async throws {
        let session = MockURLProtocol.makeSession { _ in (200, #"{"not":"an array"}"#.data(using: .utf8)!) }
        let service = CategoryService(session: session)

        await service.fetchCategories()

        #expect(service.categories.isEmpty)
        #expect(service.errorMessage == "データの形式が正しくありません")
    }

    @Test func createCategorySendsNameAndExpectedURL() async throws {
        var capturedURL: URL?
        var capturedBody: [String: Any]?
        let session = MockURLProtocol.makeSession { request in
            capturedURL = request.url
            if let bodyData = httpBodyData(from: request) {
                capturedBody = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any]
            }
            return (201, Data())
        }
        let service = CategoryService(session: session)

        let success = await service.createCategory(name: "新しいカテゴリ")

        #expect(success)
        #expect(capturedURL?.absoluteString.hasSuffix("/api/categories") == true)
        #expect(capturedBody?["name"] as? String == "新しいカテゴリ")
    }

    @Test func createCategoryReturnsFalseOnServerError() async throws {
        let session = MockURLProtocol.makeSession(statusCode: 500, data: Data())
        let service = CategoryService(session: session)

        let success = await service.createCategory(name: "新しいカテゴリ")

        #expect(!success)
    }

    @Test func fetchCategoriesSendsSearchWordAsCategoryWordQueryParam() async throws {
        var capturedURL: URL?
        let session = MockURLProtocol.makeSession { request in
            capturedURL = request.url
            return (200, self.categoryJSON(idsStartingAt: 0, count: 1))
        }
        let service = CategoryService(session: session)

        await service.fetchCategories(searchWord: "数学")

        let queryValue = capturedURL.flatMap {
            URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "categoryWord" })?.value
        }
        #expect(queryValue == "数学")
    }

    @Test func loadMoreCategoriesKeepsUsingTheActiveSearchWord() async throws {
        var capturedCategoryWords: [String] = []
        let session = MockURLProtocol.makeSession { request in
            let word = request.url
                .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
                .flatMap { $0.queryItems?.first(where: { $0.name == "categoryWord" })?.value } ?? ""
            capturedCategoryWords.append(word)

            let skip = self.skip(from: request)
            if skip == 0 {
                return (200, self.categoryJSON(idsStartingAt: 0, count: 20))
            } else {
                return (200, self.categoryJSON(idsStartingAt: 20, count: 5))
            }
        }
        let service = CategoryService(session: session)

        await service.fetchCategories(searchWord: "数学")
        await service.loadMoreCategories()

        #expect(capturedCategoryWords == ["数学", "数学"])
        #expect(service.categories.count == 25)
    }

    @Test func fetchCategoriesWithEmptySearchWordSendsEmptyCategoryWord() async throws {
        var capturedURL: URL?
        let session = MockURLProtocol.makeSession { request in
            capturedURL = request.url
            return (200, self.categoryJSON(idsStartingAt: 0, count: 1))
        }
        let service = CategoryService(session: session)

        await service.fetchCategories()

        let queryValue = capturedURL.flatMap {
            URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "categoryWord" })?.value
        }
        #expect(queryValue == "" || queryValue == nil)
    }
}
