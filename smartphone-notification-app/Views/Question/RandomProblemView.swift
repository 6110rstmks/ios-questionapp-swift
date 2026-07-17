//
//  RandomProblemView.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

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
                    
                    // ナビゲーションボタン
                    HStack(spacing: 12) {
                        if hasNextProblem {
                            Button {
                                withAnimation {
                                    currentIndex += 1
                                    showAnswer = false
                                }
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
                        }
                        
                        Button {
                            isPresented = false
                        } label: {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("終了")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("問題に挑戦")
            .navigationBarTitleDisplayMode(.inline)
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
