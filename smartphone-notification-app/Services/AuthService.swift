//
//  AuthService.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import Foundation
import Combine

@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "http://52.69.161.160/api/auth"
    private let session: URLSession

    init(session: URLSession = .cookieEnabled) {
        self.session = session
        // アプリ起動時に認証状態をチェック
        Task {
            await checkAuth()
        }
    }
    
    // ログイン
    func login(username: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/login") else {
            errorMessage = "無効なURLです"
            isLoading = false
            return false
        }
        
        let loginRequest = LoginRequest(username: username, password: password)
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(loginRequest)
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "レスポンスの取得に失敗しました"
                isLoading = false
                return false
            }
            
            
            if httpResponse.statusCode == 200 {
                // ログイン成功後、ユーザー情報を取得
                await checkAuth()
                isLoading = false
                return true
            } else {
                // エラーメッセージをパース
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    errorMessage = errorResponse.detail ?? "ログインに失敗しました。"
                } else {
                    errorMessage = "ログインに失敗しました。"
                }
                isLoading = false
                return false
            }
            
        } catch {
            errorMessage = "通信エラーが発生しました。時間をおいて再度お試しください。"
            isLoading = false
            return false
        }
    }
    
    // 認証チェック
    func checkAuth() async {
        guard let url = URL(string: "\(baseURL)/me") else {
            isAuthenticated = false
            return
        }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                isAuthenticated = false
                return
            }
            
            
            if httpResponse.statusCode == 200 {
                currentUser = try JSONDecoder().decode(User.self, from: data)
                isAuthenticated = true
            } else {
                isAuthenticated = false
                currentUser = nil
            }
            
        } catch {
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    // ログアウト
    func logout() async {
        guard let url = URL(string: "\(baseURL)/logout") else {
            return
        }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let (_, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                isAuthenticated = false
                currentUser = nil
                
                // Cookieをクリア
                if let cookies = HTTPCookieStorage.shared.cookies {
                    for cookie in cookies {
                        HTTPCookieStorage.shared.deleteCookie(cookie)
                    }
                }
            }
            
        } catch {
            print("🔐 Logout Error: \(error)")
        }
    }
}
