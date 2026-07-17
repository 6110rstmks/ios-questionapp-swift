//
//  CategoryListView.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import SwiftUI

struct CategoryListView: View {
    @StateObject private var service = CategoryService()
    @State private var searchText = ""
    
    // 検索でフィルタリングされたカテゴリ
    var filteredCategories: [SimplifiedCategory] {
        if searchText.isEmpty {
            return service.categories
        }
        return service.categories.filter { category in
            category.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if service.isLoading {
                    ProgressView("読み込み中...")
                } else if let errorMessage = service.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundStyle(.red)
                        
                        Text(errorMessage)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("再試行") {
                            Task {
                                await service.fetchCategories()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if service.categories.isEmpty {
                    ContentUnavailableView(
                        "カテゴリがありません",
                        systemImage: "list.bullet",
                        description: Text("カテゴリが見つかりませんでした")
                    )
                } else if filteredCategories.isEmpty {
                    // 検索結果が空の場合
                    ContentUnavailableView(
                        "検索結果がありません",
                        systemImage: "magnifyingglass",
                        description: Text("「\(searchText)」に一致するカテゴリが見つかりませんでした")
                    )
                } else {
                    List {
                        ForEach(filteredCategories) { category in
                            NavigationLink {
                                CategoryPageView(category: convertToFullCategory(category))
                            } label: {
                                SimpleCategoryRow(category: category)
                            }
                            .onAppear {
                                // 検索中は自動読み込みを無効化
                                guard searchText.isEmpty else { return }
                                
                                // 最後から3番目の要素が表示されたら次のページを読み込む
                                if category.id == service.categories[max(0, service.categories.count - 3)].id {
                                    Task {
                                        await service.loadMoreCategories()
                                    }
                                }
                            }
                        }
                        
                        // ローディングインジケーター（検索中は非表示）
                        if service.isLoadingMore && searchText.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        }
                        
                        // 全て読み込み完了メッセージ（検索中は非表示）
                        if !service.hasMoreData && !service.categories.isEmpty && searchText.isEmpty {
                            HStack {
                                Spacer()
                                Text("全てのカテゴリを読み込みました")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("カテゴリ一覧")
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "カテゴリを検索"
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        QuestionTestView()
                    } label: {
                        Label("テスト", systemImage: "flask")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await service.fetchCategories()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .task {
            await service.fetchCategories()
        }
    }
    
    // SimplifiedCategoryをCategoryに変換（詳細画面用）
    private func convertToFullCategory(_ simplified: SimplifiedCategory) -> Category {
        Category(
            id: simplified.id,
            name: simplified.name,
            userId: simplified.userId,
            isBlackListed: false,
            isPublic: false,
            questionCount: 0,
            incorrectedAnsweredQuestionCount: 0
        )
    }
}

// カテゴリ詳細ビュー（今は使用していない）
struct CategoryDetailView: View {
    let category: Category
    
    var body: some View {
        List {
            Section("基本情報") {
                LabeledContent("カテゴリ名", value: category.name)
                LabeledContent("ID", value: "\(category.id)")
                LabeledContent("ユーザーID", value: "\(category.userId)")
            }
            
            Section("統計") {
                LabeledContent("問題数", value: "\(category.questionCount)")
                LabeledContent("未正解数", value: "\(category.incorrectedAnsweredQuestionCount)")
            }
            
            Section("設定") {
                HStack {
                    Text("公開設定")
                    Spacer()
                    Image(systemName: category.isPublic ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundStyle(category.isPublic ? .green : .gray)
                    Text(category.isPublic ? "公開" : "非公開")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("ブラックリスト")
                    Spacer()
                    Image(systemName: category.isBlackListed ? "hand.raised.fill" : "checkmark.circle")
                        .foregroundStyle(category.isBlackListed ? .red : .green)
                    Text(category.isBlackListed ? "登録済み" : "未登録")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("カテゴリ詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CategoryListView()
}
