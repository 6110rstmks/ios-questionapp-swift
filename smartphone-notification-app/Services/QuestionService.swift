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
    
    // URLSessionにCookieを保存する設定
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.httpCookieAcceptPolicy = .always
        config.httpShouldSetCookies = true
        config.httpCookieStorage = HTTPCookieStorage.shared
        return URLSession(configuration: config)
    }()
    
    // サブカテゴリIDで問題を取得
    func fetchQuestionsBySubcategoryId(_ subcategoryId: Int) async {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/subcategory_id/\(subcategoryId)") else {
            errorMessage = "無効なURLです"
            isLoading = false
            return
        }
        
        print("🔍 問題取得開始")
        print("🔍 URL: \(url.absoluteString)")
        
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
            
            print("🔍 Status Code: \(httpResponse.statusCode)")
            
            let responseString = String(data: data, encoding: .utf8) ?? "データなし"
            print("🔍 Response Data:")
            print(responseString)
            
            guard httpResponse.statusCode == 200 else {
                errorMessage = "サーバーエラーが発生しました (Status: \(httpResponse.statusCode))"
                isLoading = false
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                questions = try decoder.decode([Question].self, from: data)
                print("🔍 問題取得成功: \(questions.count)件")
                
                // 各問題の詳細を表示
                for (index, question) in questions.enumerated() {
                    print("📝 問題 \(index + 1):")
                    print("   ID: \(question.id)")
                    print("   問題: \(question.problem)")
                    print("   回答数: \(question.answer.count)")
                    print("   ステータス: \(question.statusLabel)")
                    print("   解答回数: \(question.answerCount)")
                    if let memo = question.memo {
                        print("   メモ: \(memo)")
                    }
                    print("---")
                }
                
            } catch {
                print("🔍 デコードエラー: \(error)")
                errorMessage = "データの形式が正しくありません: \(error.localizedDescription)"
            }
            
            isLoading = false
            
        } catch {
            print("🔍 通信エラー: \(error)")
            errorMessage = "エラー: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
