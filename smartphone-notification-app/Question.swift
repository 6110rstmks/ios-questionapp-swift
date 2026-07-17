//
//  Question.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import Foundation

// 問題の正解ステータス
enum SolutionStatus: Int, Codable {
    case incorrect = 0  // 不正解
    case temporary = 1  // 保留
    case correct = 2    // 正解
}

// APIから返ってくる問題のデータ構造
struct Question: Codable, Identifiable {
    let id: Int
    let problem: String
    let answer: [String]
    let memo: String?
    let isCorrect: SolutionStatus
    let answerCount: Int
    let lastAnsweredDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case problem
        case answer
        case memo
        case isCorrect = "is_correct"
        case answerCount = "answer_count"
        case lastAnsweredDate = "last_answered_date"
    }
    
    // ステータスの色を取得
    var statusColor: String {
        switch isCorrect {
        case .correct: return "green"
        case .temporary: return "yellow"
        case .incorrect: return "red"
        }
    }
    
    // ステータスのラベルを取得
    var statusLabel: String {
        switch isCorrect {
        case .correct: return "正解"
        case .temporary: return "保留"
        case .incorrect: return "未正解"
        }
    }
}
