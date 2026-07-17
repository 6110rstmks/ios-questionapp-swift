//
//  QuestionTests.swift
//  smartphone-notification-appTests
//
//  Created by sora.sakamoto on 2026/07/18.
//

import Testing
import Foundation
@testable import smartphone_notification_app

struct QuestionTests {

    private func makeQuestion(status: SolutionStatus) -> Question {
        Question(
            id: 1,
            problem: "1 + 1 = ?",
            answer: ["2"],
            memo: nil,
            isCorrect: status,
            answerCount: 0,
            lastAnsweredDate: nil
        )
    }

    @Test func decodesSnakeCaseFieldsFromAPI() async throws {
        let json = """
        {
            "id": 10,
            "problem": "1 + 1 = ?",
            "answer": ["2"],
            "memo": "基本問題",
            "is_correct": 2,
            "answer_count": 5,
            "last_answered_date": "2026-07-18"
        }
        """.data(using: .utf8)!

        let question = try JSONDecoder().decode(Question.self, from: json)

        #expect(question.id == 10)
        #expect(question.answer == ["2"])
        #expect(question.memo == "基本問題")
        #expect(question.isCorrect == .correct)
        #expect(question.answerCount == 5)
        #expect(question.lastAnsweredDate == "2026-07-18")
    }

    @Test func decodesNullableFieldsAsNil() async throws {
        let json = """
        {
            "id": 11,
            "problem": "2 + 2 = ?",
            "answer": ["4"],
            "memo": null,
            "is_correct": 0,
            "answer_count": 0,
            "last_answered_date": null
        }
        """.data(using: .utf8)!

        let question = try JSONDecoder().decode(Question.self, from: json)

        #expect(question.memo == nil)
        #expect(question.lastAnsweredDate == nil)
        #expect(question.isCorrect == .incorrect)
    }

    @Test func statusLabelMatchesEachSolutionStatus() async throws {
        #expect(makeQuestion(status: .correct).statusLabel == "正解")
        #expect(makeQuestion(status: .temporary).statusLabel == "保留")
        #expect(makeQuestion(status: .incorrect).statusLabel == "未正解")
    }

    @Test func statusColorMatchesEachSolutionStatus() async throws {
        #expect(makeQuestion(status: .correct).statusColor == "green")
        #expect(makeQuestion(status: .temporary).statusColor == "yellow")
        #expect(makeQuestion(status: .incorrect).statusColor == "red")
    }

    @Test func solutionStatusRawValuesMatchAPIContract() async throws {
        #expect(SolutionStatus.incorrect.rawValue == 0)
        #expect(SolutionStatus.temporary.rawValue == 1)
        #expect(SolutionStatus.correct.rawValue == 2)
    }
}
