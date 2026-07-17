import SwiftUI

/// ランダムに出題される問題を表示するビュー
struct RandomProblemView: View {
    let problem: Question
    @ObservedObject var problemService: ProblemService
    @Binding var currentIndex: Int
    @Binding var isPresented: Bool
    @State private var showAnswer = false
    
    var hasNextProblem: Bool {
        currentIndex < problemService.problems.count - 1
    }

    var hasPreviousProblem: Bool {
        currentIndex > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 進捗
                    HStack {
                        Text("問題 \(currentIndex + 1) / \(problemService.problems.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("ID: \(problem.id)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // 問題カード
                    VStack(alignment: .leading, spacing: 16) {
                        Text("問題")
                            .font(.headline)
                            .foregroundStyle(.indigo)
                        
                        Text(problem.problem)
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
                                ForEach(Array(problem.answer.enumerated()), id: \.offset) { index, answer in
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
                    if let memo = problem.memo, !memo.isEmpty {
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
                    
                    // ナビゲーションボタン（左: 前の問題 / 右: 次の問題）
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
                            .opacity(hasPreviousProblem ? 1 : 0.4)
                        }
                        .disabled(!hasPreviousProblem)

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
                            .opacity(hasNextProblem ? 1 : 0.4)
                        }
                        .disabled(!hasNextProblem)
                    }
                }
                .padding()
            }
            .navigationTitle("問題に挑戦")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
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
        }
    }

    // 右スワイプ / 「次の問題」ボタンで次へ
    func goToNext() {
        guard hasNextProblem else { return }
        withAnimation {
            currentIndex += 1
            showAnswer = false
        }
    }

    // 左スワイプ / 「前の問題」ボタンで前へ
    func goToPrevious() {
        guard hasPreviousProblem else { return }
        withAnimation {
            currentIndex -= 1
            showAnswer = false
        }
    }
}

#Preview {
    @Previewable @State var currentIndex = 0
    @Previewable @State var isPresented = true
    @Previewable @StateObject var problemService = ProblemService()
    
    RandomProblemView(
        problem: Question(
            id: 1,
            problem: "サンプル問題",
            answer: ["回答1", "回答2"],
            memo: "メモ",
            isCorrect: .incorrect,
            answerCount: 0,
            lastAnsweredDate: "2026-07-17"
        ),
        problemService: problemService,
        currentIndex: $currentIndex,
        isPresented: $isPresented
    )
}
