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
            VStack(spacing: 24) {
                // 進捗
                HStack {
                    Text("問題 \(currentIndex + 1) / \(allQuestions.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("ID: \(currentQuestion.id)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // パンくずリスト
                breadcrumbSection

                // 問題カード
                VStack(alignment: .leading, spacing: 16) {
                    Text("問題")
                        .font(.headline)
                        .foregroundStyle(.indigo)

                    Text(currentQuestion.problem)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.indigo.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // 回答セクション
                VStack(alignment: .leading, spacing: 12) {
                    Button {
                        withAnimation {
                            showAnswer.toggle()
                        }
                    } label: {
                        HStack {
                            Text(showAnswer ? "回答を隠す" : "回答を表示")
                                .font(.headline)

                            Spacer()

                            Image(systemName: showAnswer ? "eye.slash" : "eye")
                        }
                        .padding()
                        .background(showAnswer ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundStyle(showAnswer ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if showAnswer {
                        VStack(spacing: 8) {
                            ForEach(Array(currentQuestion.answer.enumerated()), id: \.offset) { index, answer in
                                Text(answer)
                                    .font(.body)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                // メモ
                if let memo = currentQuestion.memo, !memo.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("メモ")
                            .font(.headline)
                            .foregroundStyle(.orange)

                        Text(memo)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            // 前の問題/次の問題ボタン。問題文の長さでスクロール量が変わっても位置がぶれないよう画面下部に固定
            HStack(spacing: 12) {
                Button {
                    goToPrevious()
                } label: {
                    HStack {
                        Image(systemName: "arrow.left.circle.fill")
                        Text("前の問題")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .opacity(hasPrevious ? 1 : 0.4)
                }
                .disabled(!hasPrevious)

                if hasNext {
                    Button {
                        goToNext()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("次の問題")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } else {
                    // 最後の問題では「次の問題」の代わりに終了ボタンを表示
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("終了する")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
            .background(.bar)
        }
        .navigationTitle("問題詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
            ToolbarItem(placement: .topBarTrailing) {
                Button("終了") {
                    dismiss()
                }
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 40)
                .onEnded { value in
                    // 横方向の動きが縦方向より明確に大きい場合のみスワイプとして扱う（縦スクロールを妨げない）
                    guard abs(value.translation.width) > abs(value.translation.height) * 2 else { return }
                    if value.translation.width > 0 {
                        goToNext()
                    } else {
                        goToPrevious()
                    }
                }
        )
        // 右スワイプが標準の「戻る」ジェスチャーとして誤認識されないよう無効化する
        .background(DisableInteractivePopGesture())
        .onChange(of: currentIndex) { oldValue, newValue in
            // インデックスが変わったら回答を隠す
            showAnswer = false
        }
    }

    // 右スワイプ / 「次の問題」ボタンで次へ
    func goToNext() {
        guard hasNext else { return }
        withAnimation {
            currentIndex += 1
        }
    }

    // 左スワイプ / 「前の問題」ボタンで前へ
    func goToPrevious() {
        guard hasPrevious else { return }
        withAnimation {
            currentIndex -= 1
        }
    }

    // パンくずリスト
    private var breadcrumbSection: some View {
        HStack(spacing: 8) {
            Text(category.name)
                .font(.caption)
                .foregroundStyle(.secondary)

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(subcategory.name)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            if let lastAnswered = currentQuestion.lastAnsweredDate {
                Text(formatDate(lastAnswered))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
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
