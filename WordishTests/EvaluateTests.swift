//
//  EvaluateTests.swift
//  WordishTests
//
//  Created by Lucas Lopez.
//


import Testing
@testable import Wordish

@MainActor
struct EvaluateTests {

    /// Creates a clean ViewModel with a known secret for testing.
    private func makeVM(secret: String) -> GameViewModel {
        let vm = GameViewModel()
        vm.secret = secret
        vm.currentRow = 0
        vm.rows = [Row()] // 1 clean row
        return vm
    }

    // MARK: - Perfect match
    @Test
    func testPerfectMatch() {
        let vm = makeVM(secret: "APPLE")

        vm.evaluate(guess: "APPLE")

        let states = vm.rows[0].tiles.map { $0.state }

        #expect(states == [.correct, .correct, .correct, .correct, .correct])
    }

    // MARK: - All letters wrong
    @Test
    func testAllWrong() {
        let vm = makeVM(secret: "APPLE")

        vm.evaluate(guess: "ZZZZZ")

        let states = vm.rows[0].tiles.map { $0.state }

        #expect(states == [.absent, .absent, .absent, .absent, .absent])
    }

    // MARK: - Duplicate letter evaluation
    @Test
    func testDuplicateLetters() {
        let vm = makeVM(secret: "APPLE")

        vm.evaluate(guess: "PAPER")

        let states = vm.rows[0].tiles.map { $0.state }

        let expected: [LetterState] = [
            .present, .present, .correct, .present, .absent
        ]

        #expect(states == expected)
    }

    // MARK: - Present letters (yellow) in different positions
    @Test
    func testPresentLetters() {
        let vm = makeVM(secret: "TRAIN")

        vm.evaluate(guess: "NITRA")

        let expected: [LetterState] = [.present, .present, .present, .present, .present]
        let states = vm.rows[0].tiles.map { $0.state }

        #expect(states == expected)
    }
}
