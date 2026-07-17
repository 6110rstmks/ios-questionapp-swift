//
//  ProblemService.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import Foundation
import Combine

@MainActor
class ProblemService: ObservableObject {
    @Published var problems: [Question] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "http://52.69.161.160/api/problems/"
    private let session: URLSession

    init(session: URLSession = .cookieEnabled) {
        self.session = session
    }
    
    // 問題を取得
    func fetchProblem(
        type: String = "random",
        solvedStatus: String = "incorrect",
        problemCount: Int = 1,
        categoryIds: [Int] = [],
        subcategoryIds: [Int] = []
    ) async {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: baseURL) else {
            errorMessage = "無効なURLです"
            isLoading = false
            return
        }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = [
                "type": type,
                "solved_status": solvedStatus,
                "problem_count": problemCount,
                "category_ids": categoryIds,
                "subcategory_ids": subcategoryIds
            ]

            request.httpBody = try JSONSerialization.data(withJSONObject: body)

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
                problems = try decoder.decode([Question].self, from: data)
            } catch {
                errorMessage = "データの形式が正しくありません: \(error.localizedDescription)"
            }

            isLoading = false

        } catch {
            errorMessage = "エラー: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
