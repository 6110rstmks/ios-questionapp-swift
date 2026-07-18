import Testing
import SwiftUI
@testable import smartphone_notification_app

@MainActor
struct RandomProblemViewTests {

    private func makeQuestion(id: Int) -> Question {
        Question(
            id: id,
            problem: "問題\(id)",
            answer: ["回答\(id)"],
            memo: nil,
            isCorrect: .incorrect,
            answerCount: 0,
            lastAnsweredDate: nil
        )
    }

    /// currentIndexをテストから読み書きできるようにするためのBinding
    private func makeView(problemCount: Int, currentIndex: Int) -> (view: RandomProblemView, index: () -> Int) {
        let service = ProblemService()
        service.problems = (0..<problemCount).map(makeQuestion)

        var storedIndex = currentIndex
        let indexBinding = Binding<Int>(
            get: { storedIndex },
            set: { storedIndex = $0 }
        )
        let isPresentedBinding = Binding<Bool>(get: { true }, set: { _ in })

        let view = RandomProblemView(
            problem: service.problems[currentIndex],
            problemService: service,
            currentIndex: indexBinding,
            isPresented: isPresentedBinding
        )

        return (view, { storedIndex })
    }

    @Test func hasNextProblemIsTrueWhenMoreProblemsRemain() async throws {
        let (view, _) = makeView(problemCount: 3, currentIndex: 0)

        #expect(view.hasNextProblem)
    }

    @Test func hasNextProblemIsFalseOnLastProblem() async throws {
        let (view, _) = makeView(problemCount: 3, currentIndex: 2)

        #expect(!view.hasNextProblem)
    }

    @Test func hasPreviousProblemIsFalseOnFirstProblem() async throws {
        let (view, _) = makeView(problemCount: 3, currentIndex: 0)

        #expect(!view.hasPreviousProblem)
    }

    @Test func hasPreviousProblemIsTrueWhenNotOnFirstProblem() async throws {
        let (view, _) = makeView(problemCount: 3, currentIndex: 1)

        #expect(view.hasPreviousProblem)
    }

    @Test func goToNextAdvancesCurrentIndex() async throws {
        let (view, index) = makeView(problemCount: 3, currentIndex: 0)

        view.goToNext()

        #expect(index() == 1)
    }

    @Test func goToNextDoesNothingOnLastProblem() async throws {
        let (view, index) = makeView(problemCount: 3, currentIndex: 2)

        view.goToNext()

        #expect(index() == 2)
    }

    @Test func goToPreviousMovesBackCurrentIndex() async throws {
        let (view, index) = makeView(problemCount: 3, currentIndex: 2)

        view.goToPrevious()

        #expect(index() == 1)
    }

    @Test func goToPreviousDoesNothingOnFirstProblem() async throws {
        let (view, index) = makeView(problemCount: 3, currentIndex: 0)

        view.goToPrevious()

        #expect(index() == 0)
    }

    @Test func singleProblemHasNeitherNextNorPrevious() async throws {
        let (view, _) = makeView(problemCount: 1, currentIndex: 0)

        #expect(!view.hasNextProblem)
        #expect(!view.hasPreviousProblem)
    }
}
