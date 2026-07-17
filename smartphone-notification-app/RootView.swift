//
//  RootView.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import SwiftUI

struct RootView: View {
    @StateObject private var authService = AuthService()
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                // ログイン済み → カテゴリ一覧を表示
                CategoryListView()
                    .environmentObject(authService)
            } else {
                // 未ログイン → ログイン画面を表示
                LoginView()
                    .environmentObject(authService)
            }
        }
    }
}

#Preview {
    RootView()
}
