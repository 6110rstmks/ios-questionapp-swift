//
//  QuestionPageView.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import SwiftUI

struct QuestionPageView: View {
    let category: Category
    let subcategory: Subcategory
    let allQuestions: [Question]
    @State private var currentIndex: Int
    
    @Environment(\.dismiss) private var dismiss
    @State private var showAnswer = false
    @State private var dragOffset: CGFloat = 0
    
    init(category: Category, subcategory: Subcategory, question: Question, allQuestions: [Question] = []) {
        self.category = category
        self.subcategory = subcategory
        
        // allQuestionsが空の場合は1つだけの配列を作る
        if allQuestions.isEmpty {
            self.allQuestions = [question]
            self._currentIndex = State(initialValue: 0)
        } else {
            self.allQuestions = allQuestions
            // 現在の問題のインデックスを見つける
            if let index = allQuestions.firstIndex(where: { $0.id == question.id }) {
                self._currentIndex = State(initialValue: index)
            } else {
                self._currentIndex = State(initialValue: 0)
            }
        }
    }
    
    private var currentQuestion: Question {
        allQuestions[currentIndex]
    }
    
    private var hasPrevious: Bool {
        currentIndex > 0
    }
    
    private var hasNext: Bool {
        currentIndex < allQuestions.count - 1
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 進捗インジケーター
                if allQuestions.count > 1 {
                    HStack {
                        Text("\(currentIndex + 1) / \(allQuestions.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        ProgressView(value: Double(currentIndex + 1), total: Double(allQuestions.count))
                            .frame(maxWidth: 200)
                    }
                    .padding(.horizontal)
                }
                
                // パンくずリスト
                breadcrumbSection
                
                // メインカード
                VStack(spacing: 0) {
                    // ヘッダー
                    headerSection
                    
                    // コンテンツ
                    VStack(spacing: 24) {
                        // 問題セクション
                        problemSection
                        
                        Divider()
                        
                        // 回答セクション
                        answerSection
                        
                        // メモセクション
                        if let memo = currentQuestion.memo, !memo.isEmpty {
                            Divider()
                            memoSection(memo: memo)
                        }
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 100
                            
                            if value.translation.width < -threshold && hasNext {
                                // 右から左にスワイプ → 次へ
                                withAnimation {
                                    goToNext()
                                }
                            } else if value.translation.width > threshold && hasPrevious {
                                // 左から右にスワイプ → 前へ
                                withAnimation {
                                    goToPrevious()
                                }
                            }
                            
                            withAnimation {
                                dragOffset = 0
                            }
                        }
                )
                
                // ナビゲーションボタン
                if allQuestions.count > 1 {
                    HStack(spacing: 12) {
                        // 前に戻るボタン
                        Button {
                            withAnimation {
                                goToPrevious()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("前へ")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(hasPrevious ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(!hasPrevious)
                        
                        // 次へ進むボタン
                        Button {
                            withAnimation {
                                goToNext()
                            }
                        } label: {
                            HStack {
                                Text("次へ")
                                Image(systemName: "chevron.right")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(hasNext ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(!hasNext)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .navigationTitle("問題詳細")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                        Text("終了")
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        cycleStatus()
                    } label: {
                        Label("ステータス変更", systemImage: "arrow.triangle.2.circlepath")
                    }
                } label: {
                    statusBadge
                }
            }
        }
        .onChange(of: currentIndex) { oldValue, newValue in
            // インデックスが変わったら回答を隠す
            showAnswer = false
        }
    }
    
    private func goToNext() {
        if hasNext {
            currentIndex += 1
        }
    }
    
    private func goToPrevious() {
        if hasPrevious {
            currentIndex -= 1
        }
    }
    
    // パンくずリスト
    private var breadcrumbSection: some View {
        HStack(spacing: 8) {
            Text(category.name)
                .font(.subheadline)
                .foregroundStyle(.blue)
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(subcategory.name)
                .font(.subheadline)
                .foregroundStyle(.blue)
            
            Spacer()
        }
    }
    
    // ヘッダー
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Question ID: \(currentQuestion.id)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                if let lastAnswered = currentQuestion.lastAnsweredDate {
                    Text(formatDate(lastAnswered))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.indigo, .purple],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    // 問題セクション
    private var problemSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.indigo)
                    .frame(width: 8, height: 8)
                
                Text("問題")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(currentQuestion.problem)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.indigo, lineWidth: 2),
                    alignment: .leading
                )
        }
    }
    
    // 回答セクション
    private var answerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation {
                    showAnswer.toggle()
                }
            } label: {
                HStack {
                    Text(showAnswer ? "🔼 回答を隠す" : "🔽 回答を表示")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(showAnswer ? Color.indigo : Color.gray.opacity(0.2))
                .foregroundStyle(showAnswer ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            if showAnswer {
                VStack(spacing: 12) {
                    ForEach(Array(currentQuestion.answer.enumerated()), id: \.offset) { index, answer in
                        Text(answer)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.1), Color.indigo.opacity(0.1)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.indigo.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    // メモセクション
    private func memoSection(memo: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 8, height: 8)
                
                Text("メモ")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(memo)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.1), Color.yellow.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange, lineWidth: 2),
                    alignment: .leading
                )
        }
    }
    
    // ステータスバッジ（ツールバー用）
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: statusIcon)
            Text(currentQuestion.statusLabel)
        }
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(statusColor)
        .clipShape(Capsule())
    }
    
    // ステータスの色
    private var statusColor: Color {
        switch currentQuestion.isCorrect {
        case .correct: return .green
        case .temporary: return .orange
        case .incorrect: return .red
        }
    }
    
    // ステータスのアイコン
    private var statusIcon: String {
        switch currentQuestion.isCorrect {
        case .correct: return "checkmark.circle.fill"
        case .temporary: return "clock.fill"
        case .incorrect: return "xmark.circle.fill"
        }
    }
    
    // ステータスをサイクル
    private func cycleStatus() {
        // TODO: APIでステータスを更新
        print("📝 ステータス更新: \(currentQuestion.statusLabel)")
    }
    
    // 日付フォーマット
    private func formatDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            formatter.locale = Locale(identifier: "ja_JP")
            return formatter.string(from: date)
        }
        return String(dateString.prefix(10))
    }
}

#Preview {
    NavigationStack {
        QuestionPageView(
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
            ),
            question: Question(
                id: 123,
                problem: "この問題の答えは何ですか？",
                answer: ["答え1", "答え2"],
                memo: "重要なポイント",
                isCorrect: .temporary,
                answerCount: 5,
                lastAnsweredDate: "2026-07-17T10:30:00Z"
            ),
            allQuestions: [
                Question(id: 123, problem: "問題1", answer: ["答え1"], memo: nil, isCorrect: .temporary, answerCount: 5, lastAnsweredDate: "2026-07-17T10:30:00Z"),
                Question(id: 124, problem: "問題2", answer: ["答え2"], memo: nil, isCorrect: .incorrect, answerCount: 3, lastAnsweredDate: "2026-07-17T10:30:00Z")
            ]
        )
    }
}
