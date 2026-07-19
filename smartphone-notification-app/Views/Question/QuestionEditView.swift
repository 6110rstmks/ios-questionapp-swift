import SwiftUI

/// 既存の問題を編集するシート
struct QuestionEditView: View {
    let questionId: Int
    let isCorrect: SolutionStatus
    let questionService: QuestionService
    var onSaved: (_ problem: String, _ answer: [String], _ memo: String) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var problem: String
    @State private var answers: [String]
    @State private var memo: String
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(
        questionId: Int,
        problem: String,
        answers: [String],
        memo: String,
        isCorrect: SolutionStatus,
        questionService: QuestionService,
        onSaved: @escaping (_ problem: String, _ answer: [String], _ memo: String) -> Void
    ) {
        self.questionId = questionId
        self.isCorrect = isCorrect
        self.questionService = questionService
        self.onSaved = onSaved
        self._problem = State(initialValue: problem)
        self._answers = State(initialValue: answers.isEmpty ? [""] : answers)
        self._memo = State(initialValue: memo)
    }

    private var isValid: Bool {
        !problem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("問題") {
                    TextField("問題文を入力", text: $problem, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("回答") {
                    ForEach(answers.indices, id: \.self) { index in
                        HStack {
                            TextField("回答 \(index + 1)", text: $answers[index])

                            if answers.count > 1 {
                                Button {
                                    answers.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Button {
                        answers.append("")
                    } label: {
                        Label("回答を追加", systemImage: "plus.circle.fill")
                    }
                }

                Section("メモ（任意）") {
                    TextField("メモを入力", text: $memo, axis: .vertical)
                        .lineLimit(2...4)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("問題を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        Task { await save() }
                    }
                    .disabled(isSaving)
                }
            }
            .overlay {
                if isSaving {
                    ProgressView()
                }
            }
        }
    }

    private func save() async {
        guard isValid else {
            errorMessage = "問題文を入力してください"
            return
        }

        isSaving = true
        errorMessage = nil

        let trimmedProblem = problem.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnswers = answers
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let trimmedMemo = memo.trimmingCharacters(in: .whitespacesAndNewlines)

        let success = await questionService.updateQuestion(
            questionId: questionId,
            problem: trimmedProblem,
            answer: trimmedAnswers,
            memo: trimmedMemo,
            isCorrect: isCorrect.rawValue
        )

        isSaving = false

        if success {
            onSaved(trimmedProblem, trimmedAnswers, trimmedMemo)
            dismiss()
        } else {
            errorMessage = "問題の更新に失敗しました"
        }
    }
}

#Preview {
    QuestionEditView(
        questionId: 1,
        problem: "1 + 1 = ?",
        answers: ["2"],
        memo: "基本問題",
        isCorrect: .incorrect,
        questionService: QuestionService(),
        onSaved: { _, _, _ in }
    )
}
