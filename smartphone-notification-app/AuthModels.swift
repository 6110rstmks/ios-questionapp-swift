//
//  AuthModels.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import Foundation

// ログインリクエスト
struct LoginRequest: Codable {
    let username: String
    let password: String
}

// ユーザー情報
struct User: Codable, Identifiable {
    let id: Int
    let username: String
    
    // 必要に応じて追加のプロパティを追加
    // let email: String?
}

// APIエラーレスポンス
struct ErrorResponse: Codable {
    let detail: String?
}
