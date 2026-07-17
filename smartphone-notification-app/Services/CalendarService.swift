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
    @Published var questionCounts: [String: Int] = [:]  // "yyyy-MM-dd": count
    @Published var isLoading = false
    @Published var errorMessage: String?
    
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
}
