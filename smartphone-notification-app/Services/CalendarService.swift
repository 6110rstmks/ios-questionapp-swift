//
//  CalendarService.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import Foundation
import Combine

@MainActor
class CalendarService: ObservableObject {
    private let baseURL = "http://52.69.161.160/api"
    private let session: URLSession

    init(session: URLSession = .cookieEnabled) {
        self.session = session
    }
    
    // カテゴリIDと日付で問題を取得（シンプル版）
    func fetchProblems(
        categoryId: Int,
        date: String,
        isCorrect: Int? = nil
    ) async -> [Question] {
        // URLを構築
        var urlString = "\(baseURL)/problems/category_id/\(categoryId)/last_answered_date/\(date)"
        
        if let isCorrect = isCorrect {
            urlString += "?is_correct=\(isCorrect)"
        }
        
        guard let url = URL(string: urlString) else {
            return []
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return []
            }

            if httpResponse.statusCode == 405 {
                return []
            }

            guard httpResponse.statusCode == 200 else {
                return []
            }

            let decoder = JSONDecoder()
            let problems = try decoder.decode([Question].self, from: data)
            return problems

        } catch {
            return []
        }
    }

    // カテゴリ内の、指定した日付それぞれの問題数を取得
    func fetchQuestionCounts(
        categoryId: Int,
        days: [String],
        isCorrect: Int? = nil
    ) async -> [String: Int] {
        guard let url = URL(string: "\(baseURL)/question_count/count/category_id/\(categoryId)/by_last_answered_date") else {
            return [:]
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            var body: [String: Any] = ["days_array": days]
            if let isCorrect {
                body["is_correct"] = isCorrect
            }
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return [:]
            }

            return try JSONDecoder().decode([String: Int].self, from: data)

        } catch {
            return [:]
        }
    }

    // カテゴリ内で最も古い回答日を取得
    func fetchOldestLastAnsweredDate(categoryId: Int, isCorrect: Int? = nil) async -> String? {
        await fetchDateBoundary(categoryId: categoryId, isCorrect: isCorrect, endpoint: "oldest_last_answered_date")
    }

    // カテゴリ内で最も新しい回答日を取得
    func fetchLatestLastAnsweredDate(categoryId: Int, isCorrect: Int? = nil) async -> String? {
        await fetchDateBoundary(categoryId: categoryId, isCorrect: isCorrect, endpoint: "latest_last_answered_date")
    }

    private func fetchDateBoundary(categoryId: Int, isCorrect: Int?, endpoint: String) async -> String? {
        var urlString = "\(baseURL)/question_count/count/category_id/\(categoryId)/\(endpoint)"
        if let isCorrect {
            urlString += "?is_correct=\(isCorrect)"
        }

        guard let url = URL(string: urlString) else {
            return nil
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }

            return Self.decodeOptionalDateString(data)

        } catch {
            return nil
        }
    }

    // レスポンスが素の文字列またはnullで返ってくるため、JSONDecoderの代わりに直接パースする
    private static func decodeOptionalDateString(_ data: Data) -> String? {
        guard let text = String(data: data, encoding: .utf8) else { return nil }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "null" else { return nil }
        return trimmed.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }
}
