//
//  QuestionServiceTests.swift
//  smartphone-notification-appTests
//
//  Created by sora.sakamoto on 2026/07/18.
//

import Testing
import Foundation
@testable import smartphone_notification_app

@MainActor
struct QuestionServiceTests {

    private let questionJSON = #"""
    [
        {
            "id": 1,
            "problem": "1 + 1 = ?",
            "answer": ["2"],
            "memo": null,
            "is_correct": 2,
            "answer_count": 3,
            "last_answered_date": "2026-07-18"
        }
    ]
    """#

    @Test func fetchQuestionsDecodesSuccessfulResponse() async throws {
        let session = MockURLProtocol.makeSession(json: questionJSON)
        let service = QuestionService(session: session)

        await service.fetchQuestionsBySubcategoryId(1)

        #expect(service.questions.count == 1)
        #expect(service.questions.first?.isCorrect == .correct)
        #expect(service.errorMessage == nil)
    }

    @Test func fetchQuestionsRequestsExpectedURL() async throws {
        var capturedURL: URL?
        let session = MockURLProtocol.makeSession { request in
            capturedURL = request.url
            return (200, "[]".data(using: .utf8)!)
        }
        let service = QuestionService(session: session)

        await service.fetchQuestionsBySubcategoryId(42)

        #expect(capturedURL?.absoluteString.hasSuffix("/questions/subcategory_id/42") == true)
    }

    @Test func fetchQuestionsSetsErrorMessageOnServerError() async throws {
        let session = MockURLProtocol.makeSession(statusCode: 500, data: Data())
        let service = QuestionService(session: session)

        await service.fetchQuestionsBySubcategoryId(1)

        #expect(service.questions.isEmpty)
        #expect(service.errorMessage != nil)
    }

    @Test func fetchQuestionsSetsErrorMessageOnMalformedData() async throws {
        let session = MockURLProtocol.makeSession(json: #"{"not":"an array"}"#)
        let service = QuestionService(session: session)

        await service.fetchQuestionsBySubcategoryId(1)

        #expect(service.questions.isEmpty)
        #expect(service.errorMessage != nil)
    }

    @Test func updateLastAnsweredDateSendsPUTToExpectedURL() async throws {
        var capturedURL: URL?
        var capturedMethod: String?
        let session = MockURLProtocol.makeSession { request in
            capturedURL = request.url
            capturedMethod = request.httpMethod
            return (200, Data())
        }
        let service = QuestionService(session: session)

        await service.updateLastAnsweredDate(questionId: 42)

        #expect(capturedURL?.absoluteString.hasSuffix("/questions/update_last_answered_date/42") == true)
        #expect(capturedMethod == "PUT")
    }

    @Test func updateLastAnsweredDateDoesNotThrowOnServerError() async throws {
        let session = MockURLProtocol.makeSession(statusCode: 500, data: Data())
        let service = QuestionService(session: session)

        await service.updateLastAnsweredDate(questionId: 42)
        // 例外を投げず、UIに影響を与える状態も変更しないことだけを確認する
        #expect(service.errorMessage == nil)
    }
}
