import SwiftUI

/// サブカテゴリ内に新しい問題を作成するシート
struct CreateQuestionView: View {
    let category: Category
    let subcategory: Subcategory
    let questionService: QuestionService
    var onCreated: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var problem = ""
    @State private var answers: [String] = [""]
    @State private var memo = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    private var isValid: Bool {
        !problem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        answers.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
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
            .navigationTitle("問題を作成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("作成") {
                        Task { await createQuestion() }
                    }
                    .disabled(!isValid || isSaving)
                }
            }
            .overlay {
                if isSaving {
                    ProgressView()
                }
            }
        }
    }

    private func createQuestion() async {
        isSaving = true
        errorMessage = nil

        let trimmedAnswers = answers
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let success = await questionService.createQuestion(
            problem: problem.trimmingCharacters(in: .whitespacesAndNewlines),
            answer: trimmedAnswers,
            memo: memo.trimmingCharacters(in: .whitespacesAndNewlines),
            categoryId: category.id,
            subcategoryId: subcategory.id
        )

        isSaving = false

        if success {
            onCreated()
            dismiss()
        } else {
            errorMessage = "問題の作成に失敗しました"
        }
    }
}

#Preview {
    CreateQuestionView(
        category: Category(
            id: 1,
            name: "サンプルカテゴリ",
            userId: 1,
            isBlackListed: false,
            isPublic: true,
            questionCount: 10,
            incorrectedAnsweredQuestionCount: 3
        ),
        subcategory: Subcategory(id: 1, name: "サンプルサブカテゴリ", categoryId: 1),
        questionService: QuestionService(),
        onCreated: {}
    )
}
