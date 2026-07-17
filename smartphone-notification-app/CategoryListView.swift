//
//  CategoryListView.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import SwiftUI

struct CategoryListView: View {
    @StateObject private var service = CategoryService()
    
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
                } else {
                    List(service.categories) { category in
                        NavigationLink {
                            CategoryPageView(category: category)
                        } label: {
                            HStack {
                                Image(systemName: category.isPublic ? "globe" : "lock.fill")
                                    .foregroundStyle(category.isPublic ? .blue : .gray)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(category.name)
                                        .font(.headline)
                                    
                                    HStack(spacing: 12) {
                                        Label("\(category.questionCount)", systemImage: "questionmark.circle")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        
                                        if category.incorrectedAnsweredQuestionCount > 0 {
                                            Label("\(category.incorrectedAnsweredQuestionCount)", systemImage: "xmark.circle")
                                                .font(.caption)
                                                .foregroundStyle(.red)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                if category.isBlackListed {
                                    Image(systemName: "hand.raised.fill")
                                        .foregroundStyle(.red)
                                        .font(.caption)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("カテゴリ一覧")
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
}

// カテゴリ詳細ビュー（仮）
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
