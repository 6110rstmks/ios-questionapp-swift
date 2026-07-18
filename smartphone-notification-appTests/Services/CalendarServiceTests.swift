//
//  CalendarServiceTests.swift
//  smartphone-notification-appTests
//
//  Created by sora.sakamoto on 2026/07/18.
//

import Testing
import Foundation
@testable import smartphone_notification_app

@MainActor
struct CalendarServiceTests {

    private let problemJSON = #"""
    [
        {
            "id": 1,
            "problem": "1 + 1 = ?",
            "answer": ["2"],
            "memo": null,
            "is_correct": 2,
            "answer_count": 1,
            "last_answered_date": "2026-07-18"
        }
    ]
    """#

    @Test func fetchProblemsReturnsDecodedResultsOnSuccess() async throws {
        let session = MockURLProtocol.makeSession(json: problemJSON)
        let service = CalendarService(session: session)

        let problems = await service.fetchProblems(categoryId: 1, date: "2026-07-18")

        #expect(problems.count == 1)
        #expect(problems.first?.id == 1)
    }

    @Test func fetchProblemsIncludesIsCorrectQueryParamWhenProvided() async throws {
        var capturedURL: URL?
        let session = MockURLProtocol.makeSession { request in
            capturedURL = request.url
            return (200, "[]".data(using: .utf8)!)
        }
        let service = CalendarService(session: session)

        _ = await service.fetchProblems(categoryId: 1, date: "2026-07-18", isCorrect: 2)

        #expect(capturedURL?.absoluteString.contains("is_correct=2") == true)
    }

    @Test func fetchProblemsReturnsEmptyArrayOnMethodNotAllowed() async throws {
        let session = MockURLProtocol.makeSession(statusCode: 405, data: Data())
        let service = CalendarService(session: session)

        let problems = await service.fetchProblems(categoryId: 1, date: "2026-07-18")

        #expect(problems.isEmpty)
    }

    @Test func fetchProblemsReturnsEmptyArrayOnServerError() async throws {
        let session = MockURLProtocol.makeSession(statusCode: 500, data: Data())
        let service = CalendarService(session: session)

        let problems = await service.fetchProblems(categoryId: 1, date: "2026-07-18")

        #expect(problems.isEmpty)
    }

    @Test func fetchProblemsReturnsEmptyArrayOnMalformedData() async throws {
        let session = MockURLProtocol.makeSession(json: #"{"not":"an array"}"#)
        let service = CalendarService(session: session)

        let problems = await service.fetchProblems(categoryId: 1, date: "2026-07-18")

        #expect(problems.isEmpty)
    }

    @Test func fetchQuestionCountsDecodesSuccessfulResponse() async throws {
        let session = MockURLProtocol.makeSession(json: #"{"2026-07-01": 2, "2026-07-02": 0}"#)
        let service = CalendarService(session: session)

        let counts = await service.fetchQuestionCounts(categoryId: 1, days: ["2026-07-01", "2026-07-02"])

        #expect(counts["2026-07-01"] == 2)
        #expect(counts["2026-07-02"] == 0)
    }

    @Test func fetchQuestionCountsSendsDaysArrayAndIsCorrectInBody() async throws {
        var capturedBody: [String: Any]?
        let session = MockURLProtocol.makeSession { request in
            if let bodyData = httpBodyData(from: request) {
                capturedBody = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any]
            }
            return (200, "{}".data(using: .utf8)!)
        }
        let service = CalendarService(session: session)

        _ = await service.fetchQuestionCounts(categoryId: 1, days: ["2026-07-01"], isCorrect: 2)

        #expect(capturedBody?["days_array"] as? [String] == ["2026-07-01"])
        #expect(capturedBody?["is_correct"] as? Int == 2)
    }

    @Test func fetchQuestionCountsOmitsIsCorrectWhenNil() async throws {
        var capturedBody: [String: Any]?
        let session = MockURLProtocol.makeSession { request in
            if let bodyData = httpBodyData(from: request) {
                capturedBody = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any]
            }
            return (200, "{}".data(using: .utf8)!)
        }
        let service = CalendarService(session: session)

        _ = await service.fetchQuestionCounts(categoryId: 1, days: ["2026-07-01"])

        #expect(capturedBody?["is_correct"] == nil)
    }

    @Test func fetchQuestionCountsReturnsEmptyDictionaryOnServerError() async throws {
        let session = MockURLProtocol.makeSession(statusCode: 500, data: Data())
        let service = CalendarService(session: session)

        let counts = await service.fetchQuestionCounts(categoryId: 1, days: ["2026-07-01"])

        #expect(counts.isEmpty)
    }

    @Test func fetchOldestLastAnsweredDateDecodesQuotedString() async throws {
        let session = MockURLProtocol.makeSession(data: #""2026-01-15""#.data(using: .utf8)!)
        let service = CalendarService(session: session)

        let date = await service.fetchOldestLastAnsweredDate(categoryId: 1)

        #expect(date == "2026-01-15")
    }

    @Test func fetchOldestLastAnsweredDateReturnsNilWhenResponseIsNull() async throws {
        let session = MockURLProtocol.makeSession(data: "null".data(using: .utf8)!)
        let service = CalendarService(session: session)

        let date = await service.fetchOldestLastAnsweredDate(categoryId: 1)

        #expect(date == nil)
    }

    @Test func fetchOldestLastAnsweredDateIncludesIsCorrectQueryParamAndCorrectPath() async throws {
        var capturedURL: URL?
        let session = MockURLProtocol.makeSession { request in
            capturedURL = request.url
            return (200, "null".data(using: .utf8)!)
        }
        let service = CalendarService(session: session)

        _ = await service.fetchOldestLastAnsweredDate(categoryId: 1, isCorrect: 0)

        #expect(capturedURL?.absoluteString.contains("oldest_last_answered_date") == true)
        #expect(capturedURL?.absoluteString.contains("is_correct=0") == true)
    }

    @Test func fetchLatestLastAnsweredDateUsesLatestEndpoint() async throws {
        var capturedURL: URL?
        let session = MockURLProtocol.makeSession { request in
            capturedURL = request.url
            return (200, #""2026-07-18""#.data(using: .utf8)!)
        }
        let service = CalendarService(session: session)

        let date = await service.fetchLatestLastAnsweredDate(categoryId: 1)

        #expect(date == "2026-07-18")
        #expect(capturedURL?.absoluteString.contains("latest_last_answered_date") == true)
    }

    @Test func fetchLatestLastAnsweredDateReturnsNilOnServerError() async throws {
        let session = MockURLProtocol.makeSession(statusCode: 500, data: Data())
        let service = CalendarService(session: session)

        let date = await service.fetchLatestLastAnsweredDate(categoryId: 1)

        #expect(date == nil)
    }
}
