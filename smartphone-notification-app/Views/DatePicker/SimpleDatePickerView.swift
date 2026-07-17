//
//  SimpleDatePickerView.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import SwiftUI

struct SimpleDatePickerView: View {
    let category: Category
    @StateObject private var calendarService = CalendarService()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var selectedFilter: SolutionStatus? = .incorrect
    @State private var problems: [Question] = []
    @State private var isLoadingProblems = false
    
    private var filterValue: Int? {
        selectedFilter?.rawValue
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 日付選択
                VStack(alignment: .leading, spacing: 12) {
                    Text("日付を選択")
                        .font(.headline)
                    
                    DatePicker(
                        "日付",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .onChange(of: selectedDate) { oldValue, newValue in
                        Task {
                            await loadProblems()
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // フィルター選択
                VStack(alignment: .leading, spacing: 12) {
                    Text("ステータスフィルター")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        FilterButton(
                            title: "All",
                            isSelected: selectedFilter == nil,
                            color: .gray
                        ) {
                            selectedFilter = nil
                            Task { await loadProblems() }
                        }
                        
                        FilterButton(
                            title: "未正解",
                            isSelected: selectedFilter == .incorrect,
                            color: .red
                        ) {
                            selectedFilter = .incorrect
                            Task { await loadProblems() }
                        }
                        
                        FilterButton(
                            title: "保留",
                            isSelected: selectedFilter == .temporary,
                            color: .orange
                        ) {
                            selectedFilter = .temporary
                            Task { await loadProblems() }
                        }
                        
                        FilterButton(
                            title: "正解",
                            isSelected: selectedFilter == .correct,
                            color: .green
                        ) {
                            selectedFilter = .correct
                            Task { await loadProblems() }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 問題数表示
                HStack {
                    Text("該当問題数: \(problems.count)件")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if isLoadingProblems {
                        ProgressView()
                    }
                }
                .padding(.horizontal)
                
                // 問題リスト
                if problems.isEmpty && !isLoadingProblems {
                    ContentUnavailableView(
                        "問題がありません",
                        systemImage: "calendar",
                        description: Text("この日付には問題がありません")
                    )
                } else {
                    List(problems) { problem in
                        NavigationLink {
                            // TODO: カテゴリとサブカテゴリ情報が必要
                            // 仮の値で表示
                            QuestionPageView(
                                category: category,
                                subcategory: Subcategory(id: 0, name: "未設定", categoryId: category.id),
                                question: problem
                            )
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("ID: \(problem.id)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    StatusBadge(status: problem.isCorrect)
                                }
                                
                                Text(problem.problem)
                                    .font(.body)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("日付で問題を検索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await loadProblems()
        }
    }
    
    private func loadProblems() async {
        isLoadingProblems = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        
        problems = await calendarService.fetchProblems(
            categoryId: category.id,
            date: dateString,
            isCorrect: filterValue
        )
        
        isLoadingProblems = false
    }
}

#Preview {
    SimpleDatePickerView(
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
