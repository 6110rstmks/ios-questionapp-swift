//
//  HomeView.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var problemService = ProblemService()
    @State private var showProblem = false
    @State private var currentProblemIndex = 0
    
    var currentProblem: Question? {
        guard !problemService.problems.isEmpty,
              currentProblemIndex < problemService.problems.count else {
            return nil
        }
        return problemService.problems[currentProblemIndex]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // ダークスケールの背景
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // メインボタン
                    VStack(spacing: 20) {
                        // カテゴリ一覧ボタン
                        NavigationLink {
                            CategoryListView()
                        } label: {
                            HomeButtonView(
                                title: "カテゴリ一覧",
                                subtitle: "すべてのカテゴリを表示",
                                icon: "folder.fill",
                                gradient: [Color(white: 0.2), Color(white: 0.3)]
                            )
                        }
                        
                        // 問題出題ボタン
                        Button {
                            Task {
                                await fetchRandomProblem()
                            }
                        } label: {
                            HomeButtonView(
                                title: "問題に挑戦",
                                subtitle: "ランダムに未正解問題を出題",
                                icon: "play.circle.fill",
                                gradient: [Color(white: 0.25), Color(white: 0.35)]
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // フッター
                    if problemService.isLoading {
                        HStack {
                            ProgressView()
                                .tint(.white)
                            Text("問題を取得中...")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await authService.logout()
                        }
                    } label: {
                        Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    .tint(.white)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(isPresented: $showProblem) {
                if let problem = currentProblem {
                    RandomProblemView(
                        problem: problem,
                        problemService: problemService,
                        currentIndex: $currentProblemIndex,
                        isPresented: $showProblem
                    )
                }
            }
        }
    }
    
    private func fetchRandomProblem() async {
        await problemService.fetchProblem(
            type: "random",
            solvedStatus: "incorrect",
            problemCount: 10
        )
        
        if !problemService.problems.isEmpty {
            currentProblemIndex = 0
            showProblem = true
        }
    }
}

#Preview {
    HomeView()
}
