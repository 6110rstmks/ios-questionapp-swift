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
}
