//
//  CategoryService.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import Foundation
import Combine

// カテゴリAPIと通信するサービス
@MainActor
class CategoryService: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "http://52.69.161.160/api"
    
    // URLSessionにCookieを保存する設定
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.httpCookieAcceptPolicy = .always
        config.httpShouldSetCookies = true
        config.httpCookieStorage = HTTPCookieStorage.shared
        return URLSession(configuration: config)
    }()
    
    // カテゴリ一覧を取得
    func fetchCategories() async {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/categories/all_categories") else {
            errorMessage = "無効なURLです"
            isLoading = false
            return
        }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "レスポンスの取得に失敗しました"
                isLoading = false
                return
            }
            
            print("📡 API Status Code: \(httpResponse.statusCode)")
            print("📡 API Response: \(String(data: data, encoding: .utf8) ?? "データなし")")
            
            guard httpResponse.statusCode == 200 else {
                errorMessage = "サーバーエラーが発生しました (Status: \(httpResponse.statusCode))"
                isLoading = false
                return
            }
            
            // レスポンスのデータ構造に応じてデコード方法を調整
            let decoder = JSONDecoder()
            
            do {
                // 配列として直接デコード
                categories = try decoder.decode([Category].self, from: data)
                print("📡 カテゴリ取得成功: \(categories.count)件")
            } catch {
                let jsonString = String(data: data, encoding: .utf8) ?? "不明"
                print("📡 デコードエラー: \(error)")
                print("📡 API Response: \(jsonString)")
                errorMessage = "データの形式が正しくありません: \(error.localizedDescription)"
            }
            
            isLoading = false
            
        } catch {
            errorMessage = "エラー: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
