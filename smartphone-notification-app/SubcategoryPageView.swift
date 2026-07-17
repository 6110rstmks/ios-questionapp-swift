//
//  SubcategoryPageView.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import SwiftUI

struct SubcategoryPageView: View {
    let category: Category
    let subcategory: Subcategory
    @StateObject private var questionService = QuestionService()
    @State private var showAnswer = false
    @State private var searchText = ""
    
    // 統計情報を計算
    var questionCount: Int {
        questionService.questions.count
    }
    
    var correctCount: Int {
        questionService.questions.filter { $0.isCorrect == .correct }.count
    }
    
    var temporaryCount: Int {
        questionService.questions.filter { $0.isCorrect == .temporary }.count
    }
    
    var incorrectCount: Int {
        questionService.questions.filter { $0.isCorrect == .incorrect }.count
    }
    
    // 検索フィルタリング
    var filteredQuestions: [Question] {
        if searchText.isEmpty {
            return questionService.questions
        }
        return questionService.questions.filter { question in
            question.problem.localizedCaseInsensitiveContains(searchText) ||
            question.answer.joined(separator: " ").localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 統計カード
            if !questionService.isLoading && questionService.errorMessage == nil {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        StatCard(title: "全問題", count: questionCount, color: .blue, icon: "doc.text")
                        StatCard(title: "正解", count: correctCount, color: .green, icon: "checkmark.circle.fill")
                        StatCard(title: "保留", count: temporaryCount, color: .orange, icon: "clock.fill")
                        StatCard(title: "未正解", count: incorrectCount, color: .red, icon: "xmark.circle.fill")
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
                
                Divider()
                
                // コントロール
                HStack(spacing: 12) {
                    Button {
                        showAnswer.toggle()
                    } label: {
                        Label(showAnswer ? "回答を隠す" : "回答を表示", systemImage: showAnswer ? "eye.slash" : "eye")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(showAnswer ? .blue : .gray)
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
            }
            
            // 問題一覧
            if questionService.isLoading {
                ProgressView("読み込み中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = questionService.errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.red)
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("再試行") {
                        Task {
                            await questionService.fetchQuestionsBySubcategoryId(subcategory.id)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredQuestions.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? "問題がありません" : "検索結果がありません",
                    systemImage: "doc.text",
                    description: Text(searchText.isEmpty ? "このサブカテゴリにはまだ問題がありません" : "別のキーワードで検索してください")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredQuestions) { question in
                            QuestionCard(question: question, showAnswer: showAnswer)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(subcategory.name)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "問題を検索")
        .task {
            await questionService.fetchQuestionsBySubcategoryId(subcategory.id)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await questionService.fetchQuestionsBySubcategoryId(subcategory.id)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
}

// 統計カード
struct StatCard: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.secondary)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .frame(minWidth: 80)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// 問題カード
struct QuestionCard: View {
    let question: Question
    let showAnswer: Bool
    
    var statusColor: Color {
        switch question.isCorrect {
        case .correct: return .green
        case .temporary: return .orange
        case .incorrect: return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack {
                Text("ID: \(question.id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: statusIcon)
                    Text(question.statusLabel)
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor)
                .clipShape(Capsule())
            }
            
            Divider()
            
            // 問題文
            VStack(alignment: .leading, spacing: 4) {
                Text("問題")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Text(question.problem)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // 回答（表示切替可能）
            if showAnswer {
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("回答")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    ForEach(Array(question.answer.enumerated()), id: \.offset) { index, answer in
                        Text(answer)
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
            
            // メモ
            if let memo = question.memo, !memo.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("メモ")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Text(memo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // フッター情報
            HStack(spacing: 12) {
                Label("\(question.answerCount)", systemImage: "repeat")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                if let lastAnswered = question.lastAnsweredDate {
                    Label(formatDate(lastAnswered), systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(statusColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    var statusIcon: String {
        switch question.isCorrect {
        case .correct: return "checkmark.circle.fill"
        case .temporary: return "clock.fill"
        case .incorrect: return "xmark.circle.fill"
        }
    }
    
    func formatDate(_ dateString: String) -> String {
        // 簡易的な日付フォーマット
        // 実際のAPIの日付形式に合わせて調整してください
        if let date = ISO8601DateFormatter().date(from: dateString) {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        return dateString
    }
}

#Preview {
    NavigationStack {
        SubcategoryPageView(
            category: Category(
                id: 1,
                name: "サンプルカテゴリ",
                userId: 1,
                isBlackListed: false,
                isPublic: true,
                questionCount: 10,
                incorrectedAnsweredQuestionCount: 3
            ),
            subcategory: Subcategory(
                id: 1,
                name: "サンプルサブカテゴリ",
                categoryId: 1
            )
        )
    }
}
