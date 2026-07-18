//
//  SubcategoryService.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import Foundation
import Combine

@MainActor
class SubcategoryService: ObservableObject {
    @Published var subcategories: [Subcategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "http://52.69.161.160/api/subcategories"
    private let session: URLSession

    init(session: URLSession = .cookieEnabled) {
        self.session = session
    }
    
    // カテゴリIDでサブカテゴリ一覧を取得
    func fetchSubcategories(byCategoryId categoryId: Int, searchWord: String = "") async {
        isLoading = true
        errorMessage = nil
        
        var urlString = "\(baseURL)/category_id/\(categoryId)"
        if !searchWord.isEmpty {
            urlString += "?searchSubcategoryName=\(searchWord)"
        }
        
        guard let url = URL(string: urlString) else {
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
                subcategories = try decoder.decode([Subcategory].self, from: data)
            } catch {
                errorMessage = "データの形式が正しくありません: \(error.localizedDescription)"
            }

            isLoading = false

        } catch {
            errorMessage = "エラー: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // 新しいサブカテゴリを作成
    func createSubcategory(name: String, categoryId: Int) async -> Subcategory? {
        guard let url = URL(string: "\(baseURL)/") else {
            return nil
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: Any] = ["name": name, "category_id": categoryId]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return nil
            }

            return try JSONDecoder().decode(Subcategory.self, from: data)

        } catch {
            return nil
        }
    }
}
