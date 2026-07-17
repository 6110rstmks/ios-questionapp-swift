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
    
    // URLSessionにCookieを保存する設定
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.httpCookieAcceptPolicy = .always
        config.httpShouldSetCookies = true
        config.httpCookieStorage = HTTPCookieStorage.shared
        return URLSession(configuration: config)
    }()
    
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
        
        print("🎲 問題取得開始")
        print("🎲 URL: \(url.absoluteString)")
        print("🎲 Type: \(type), Status: \(solvedStatus), Count: \(problemCount)")
        
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
            
            print("🎲 Status Code: \(httpResponse.statusCode)")
            
            let responseString = String(data: data, encoding: .utf8) ?? "データなし"
            print("🎲 Response Data:")
            print(responseString)
            
            guard httpResponse.statusCode == 200 else {
                errorMessage = "サーバーエラーが発生しました (Status: \(httpResponse.statusCode))"
                isLoading = false
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                problems = try decoder.decode([Question].self, from: data)
                print("🎲 問題取得成功: \(problems.count)件")
                
                for (index, problem) in problems.enumerated() {
                    print("📝 問題 \(index + 1): ID \(problem.id)")
                }
                
            } catch {
                print("🎲 デコードエラー: \(error)")
                errorMessage = "データの形式が正しくありません: \(error.localizedDescription)"
            }
            
            isLoading = false
            
        } catch {
            print("🎲 通信エラー: \(error)")
            errorMessage = "エラー: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
