//
//  QuestionService.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import Foundation
import Combine

@MainActor
class QuestionService: ObservableObject {
    @Published var questions: [Question] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "http://52.69.161.160/api/questions"
    private let session: URLSession

    init(session: URLSession = .cookieEnabled) {
        self.session = session
    }
    
    // サブカテゴリIDで問題を取得
    func fetchQuestionsBySubcategoryId(_ subcategoryId: Int) async {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/subcategory_id/\(subcategoryId)") else {
            errorMessage = "無効なURLです"
            isLoading = false
            return
        }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "レスポンスの取得に失敗しました"
                isLoading = false
                return
            }

            guard httpResponse.statusCode == 200 else {
                errorMessage = "サーバーエラーが発生しました (Status: \(httpResponse.statusCode))"
                isLoading = false
                return
            }

            let decoder = JSONDecoder()

            do {
                questions = try decoder.decode([Question].self, from: data)
            } catch {
                errorMessage = "データの形式が正しくありません: \(error.localizedDescription)"
            }

            isLoading = false

        } catch {
            errorMessage = "エラー: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // 問題の最終回答日を最新日に更新
    func updateLastAnsweredDate(questionId: Int) async {
        guard let url = URL(string: "\(baseURL)/update_last_answered_date/\(questionId)") else {
            return
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            _ = try await session.data(for: request)
        } catch {
            // 記録更新の失敗は画面表示に影響させない
        }
    }
}
