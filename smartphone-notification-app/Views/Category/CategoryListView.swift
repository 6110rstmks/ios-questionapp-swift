import SwiftUI

struct CategoryListView: View {
    @StateObject private var service = CategoryService()
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var showCreateCategoryAlert = false
    @State private var newCategoryName = ""

    // アルファベット（辞書）順に並べたカテゴリ。無限スクロールの「あと3件」判定もこの並びを基準にする
    var sortedCategories: [SimplifiedCategory] {
        service.categories.sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
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
                } else if sortedCategories.isEmpty {
                    // 検索結果が空の場合
                    ContentUnavailableView(
                        "検索結果がありません",
                        systemImage: "magnifyingglass",
                        description: Text("「\(searchText)」に一致するカテゴリが見つかりませんでした")
                    )
                } else {
                    List {
                        ForEach(sortedCategories) { category in
                            NavigationLink {
                                CategoryPageView(category: convertToFullCategory(category))
                            } label: {
                                SimpleCategoryRow(category: category)
                            }
                            .onAppear {
                                // 表示順（アルファベット順）で最後から3番目が見えたら次のページを読み込む
                                // 検索中でもサーバー側で絞り込んだ続きを取得できる
                                if category.id == sortedCategories[max(0, sortedCategories.count - 3)].id {
                                    Task {
                                        await service.loadMoreCategories()
                                    }
                                }
                            }
                        }

                        if service.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        }

                        if !service.hasMoreData && !service.categories.isEmpty {
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
            .onChange(of: searchText) { _, newValue in
                // 入力のたびに叩かないよう少し待ってからサーバー側で検索する（未読み込みのカテゴリも対象になる）
                searchTask?.cancel()
                searchTask = Task {
                    try? await Task.sleep(for: .milliseconds(300))
                    guard !Task.isCancelled else { return }
                    await service.fetchCategories(searchWord: newValue)
                }
            }
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
                        newCategoryName = ""
                        showCreateCategoryAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await service.fetchCategories(searchWord: searchText)
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .alert("新しいカテゴリ", isPresented: $showCreateCategoryAlert) {
                TextField("カテゴリ名", text: $newCategoryName)
                Button("作成") {
                    Task { await createCategory() }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("カテゴリ名を入力してください")
            }
        }
        .task {
            await service.fetchCategories()
        }
    }

    private func createCategory() async {
        let name = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        let success = await service.createCategory(name: name)
        if success {
            await service.fetchCategories(searchWord: searchText)
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
