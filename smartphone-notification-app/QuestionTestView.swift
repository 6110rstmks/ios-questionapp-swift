//
//  QuestionTestView.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import SwiftUI

struct QuestionTestView: View {
    @StateObject private var service = QuestionService()
    @State private var testQuestionId = "1152"
    
    let testIds = ["1152", "2523"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                testControlSection
                
                Divider()
                
                resultSection
            }
            .padding()
            .navigationTitle("Question API テスト")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("コンソールをチェック") {
                        print("📋 Xcodeのコンソール（⌘⇧Y）を確認してください")
                    }
                    .font(.caption)
                }
            }
        }
    }
    
    // テストコントロールセクション
    private var testControlSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("テスト用Question ID")
                .font(.headline)
            
            HStack(spacing: 12) {
                ForEach(testIds, id: \.self) { id in
                    Button(id) {
                        testQuestionId = id
                    }
                    .buttonStyle(.bordered)
                    .tint(testQuestionId == id ? .blue : .gray)
                }
            }
            
            Button("データ取得") {
                Task {
                    if let id = Int(testQuestionId) {
                        print("\n========== Question ID \(id) のテスト開始 ==========")
                        await service.fetchQuestionsBySubcategoryId(id)
                        print("========== テスト完了 ==========\n")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // 結果表示セクション
    @ViewBuilder
    private var resultSection: some View {
        if service.isLoading {
            ProgressView("読み込み中...")
        } else if let errorMessage = service.errorMessage {
            errorView(message: errorMessage)
        } else if service.questions.isEmpty {
            emptyView
        } else {
            questionsList
        }
    }
    
    // エラービュー
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.red)
            Text(message)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
        }
    }
    
    // 空のビュー
    private var emptyView: some View {
        Text("データがありません")
            .foregroundStyle(.secondary)
    }
    
    // 問題リスト
    private var questionsList: some View {
        List(service.questions) { question in
            QuestionTestRow(question: question)
        }
    }
}

// 問題行コンポーネント
struct QuestionTestRow: View {
    let question: Question
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerSection
            
            problemSection
            
            answerSection
            
            footerSection
        }
        .padding(.vertical, 8)
    }
    
    private var headerSection: some View {
        HStack {
            Text("ID: \(question.id)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            statusBadge
        }
    }
    
    private var statusBadge: some View {
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
    
    private var problemSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("質問:")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(question.problem)
                .font(.headline)
        }
    }
    
    private var answerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("回答:")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ForEach(Array(question.answer.enumerated()), id: \.offset) { index, answer in
                Text(answer)
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
        }
    }
    
    private var footerSection: some View {
        HStack {
            Text("解答回数: \(question.answerCount)")
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            if let lastAnswered = question.lastAnsweredDate {
                Text("• 最終: \(lastAnswered)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var statusColor: Color {
        switch question.isCorrect {
        case .correct: return .green
        case .temporary: return .orange
        case .incorrect: return .red
        }
    }
    
    private var statusIcon: String {
        switch question.isCorrect {
        case .correct: return "checkmark.circle.fill"
        case .temporary: return "clock.fill"
        case .incorrect: return "xmark.circle.fill"
        }
    }
}

#Preview {
    QuestionTestView()
}
