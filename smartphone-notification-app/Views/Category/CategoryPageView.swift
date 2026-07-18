//
//  CategoryPageView.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import SwiftUI

struct CategoryPageView: View {
    let category: Category
    @StateObject private var service = SubcategoryService()
    @State private var searchText = ""
    @State private var showDatePicker = false
    @State private var showCreateSubcategoryAlert = false
    @State private var newSubcategoryName = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // カテゴリ情報ヘッダー
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 16) {
                            Label("\(category.questionCount)", systemImage: "questionmark.circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            if category.incorrectedAnsweredQuestionCount > 0 {
                                Label("\(category.incorrectedAnsweredQuestionCount)", systemImage: "xmark.circle")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                            
                            Image(systemName: category.isPublic ? "globe" : "lock.fill")
                                .foregroundStyle(category.isPublic ? .blue : .gray)
                                .font(.caption)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
            }
            
            // サブカテゴリ一覧
            Group {
                if service.isLoading {
                    ProgressView("読み込み中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                await service.fetchSubcategories(byCategoryId: category.id)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if service.subcategories.isEmpty {
                    ContentUnavailableView(
                        "サブカテゴリがありません",
                        systemImage: "folder",
                        description: Text("このカテゴリにはまだサブカテゴリがありません")
                    )
                } else {
                    List(service.subcategories) { subcategory in
                        NavigationLink {
                            SubcategoryPageView(
                                category: category,
                                subcategory: subcategory
                            )
                        } label: {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundStyle(.orange)
                                
                                Text(subcategory.name)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
        .navigationTitle("サブカテゴリ一覧")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "サブカテゴリを検索")
        .onChange(of: searchText) { oldValue, newValue in
            Task {
                await service.fetchSubcategories(byCategoryId: category.id, searchWord: newValue)
            }
        }
        .task {
            await service.fetchSubcategories(byCategoryId: category.id)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showDatePicker = true
                } label: {
                    Label("日付で検索", systemImage: "calendar")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    newSubcategoryName = ""
                    showCreateSubcategoryAlert = true
                } label: {
                    Image(systemName: "plus")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await service.fetchSubcategories(byCategoryId: category.id, searchWord: searchText)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .alert("新しいサブカテゴリ", isPresented: $showCreateSubcategoryAlert) {
            TextField("サブカテゴリ名", text: $newSubcategoryName)
            Button("作成") {
                Task { await createSubcategory() }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("サブカテゴリ名を入力してください")
        }
        .sheet(isPresented: $showDatePicker) {
            SimpleDatePickerView(category: category)
        }
    }

    private func createSubcategory() async {
        let name = newSubcategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        let created = await service.createSubcategory(name: name, categoryId: category.id)
        if created != nil {
            await service.fetchSubcategories(byCategoryId: category.id, searchWord: searchText)
        }
    }
}

#Preview {
    NavigationStack {
        CategoryPageView(
            category: Category(
                id: 1,
                name: "サンプルカテゴリ",
                userId: 1,
                isBlackListed: false,
                isPublic: true,
                questionCount: 10,
                incorrectedAnsweredQuestionCount: 3
            )
        )
    }
}
