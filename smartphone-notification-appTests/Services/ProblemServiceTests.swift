//
//  ProblemServiceTests.swift
//  smartphone-notification-appTests
//
//  Created by sora.sakamoto on 2026/07/18.
//

import Testing
import Foundation
@testable import smartphone_notification_app

@MainActor
struct ProblemServiceTests {

    private let problemJSON = #"""
    [
        {
            "id": 1,
            "problem": "1 + 1 = ?",
            "answer": ["2"],
            "memo": null,
            "is_correct": 0,
            "answer_count": 0,
            "last_answered_date": null
        }
    ]
    """#

    @Test func fetchProblemDecodesSuccessfulResponse() async throws {
        let session = MockURLProtocol.makeSession(json: problemJSON)
        let service = ProblemService(session: session)

        await service.fetchProblem()

        #expect(service.problems.count == 1)
        #expect(service.errorMessage == nil)
    }

    @Test func fetchProblemSendsRequestedParametersInBody() async throws {
        var capturedBody: [String: Any]?
        let session = MockURLProtocol.makeSession { request in
            if let bodyData = httpBodyData(from: request) {
                capturedBody = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any]
            }
            return (200, "[]".data(using: .utf8)!)
        }
        let service = ProblemService(session: session)

        await service.fetchProblem(
            type: "specific",
            solvedStatus: "correct",
            problemCount: 5,
            categoryIds: [1, 2],
            subcategoryIds: [3]
        )

        #expect(capturedBody?["type"] as? String == "specific")
        #expect(capturedBody?["solved_status"] as? String == "correct")
        #expect(capturedBody?["problem_count"] as? Int == 5)
        #expect(capturedBody?["category_ids"] as? [Int] == [1, 2])
        #expect(capturedBody?["subcategory_ids"] as? [Int] == [3])
    }

    @Test func fetchProblemSetsErrorMessageOnServerError() async throws {
        let session = MockURLProtocol.makeSession(statusCode: 500, data: Data())
        let service = ProblemService(session: session)

        await service.fetchProblem()

        #expect(service.problems.isEmpty)
        #expect(service.errorMessage != nil)
    }

    @Test func fetchProblemSetsErrorMessageOnMalformedData() async throws {
        let session = MockURLProtocol.makeSession(json: #"{"not":"an array"}"#)
        let service = ProblemService(session: session)

        await service.fetchProblem()

        #expect(service.problems.isEmpty)
        #expect(service.errorMessage != nil)
    }
}
