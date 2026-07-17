//
//  CategoryService.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import Foundation
import Combine

// 軽量なカテゴリデータ（問題数などを含まない）
struct SimplifiedCategory: Codable, Identifiable {
    let id: Int
    let name: String
    let userId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case userId = "user_id"
    }
}

// カテゴリAPIと通信するサービス
@MainActor
class CategoryService: ObservableObject {
    @Published var categories: [SimplifiedCategory] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasMoreData = true
    
    private let baseURL = "http://52.69.161.160/api"
    private let pageSize = 20 // 1回で取得する件数
    private var currentPage = 0
    private let session: URLSession

    init(session: URLSession = .cookieEnabled) {
        self.session = session
    }
    
    // 最初のページを取得
    func fetchCategories() async {
        categories = []
        currentPage = 0
        hasMoreData = true
        await loadMoreCategories()
    }
    
    // 追加のカテゴリを取得（ページネーション）
    func loadMoreCategories() async {
        guard !isLoading && !isLoadingMore && hasMoreData else { return }
        
        if currentPage == 0 {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        
        errorMessage = nil
        
        let skip = currentPage * pageSize
        guard let url = URL(string: "\(baseURL)/categories/home?skip=\(skip)&limit=\(pageSize)&categoryWord=&subcategoryWord=&questionWord=&answerWord=") else {
            errorMessage = "無効なURLです"
            isLoading = false
            isLoadingMore = false
            return
        }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "レスポンスの取得に失敗しました"
                isLoading = false
                isLoadingMore = false
                return
            }

            guard httpResponse.statusCode == 200 else {
                errorMessage = "サーバーエラーが発生しました (Status: \(httpResponse.statusCode))"
                isLoading = false
                isLoadingMore = false
                return
            }

            let decoder = JSONDecoder()

            do {
                let newCategories = try decoder.decode([SimplifiedCategory].self, from: data)

                if newCategories.isEmpty {
                    hasMoreData = false
                } else {
                    categories.append(contentsOf: newCategories)
                    currentPage += 1

                    // 取得した件数がpageSizeより少ない場合、これ以上データがない
                    if newCategories.count < pageSize {
                        hasMoreData = false
                    }
                }

            } catch {
                errorMessage = "データの形式が正しくありません"
            }

            isLoading = false
            isLoadingMore = false

        } catch {
            errorMessage = "エラー: \(error.localizedDescription)"
            isLoading = false
            isLoadingMore = false
        }
    }
}
