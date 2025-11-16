//
//  WordishTests.swift
//  WordishTests
//
//  Created by Lucas Lopez.
//

//
//  WordishTests.swift
//  WordishTests
//

import Testing
@testable import Wordish
@MainActor

/// Small sanity tests for the app.
/// (Full evaluation logic tests in `EvaluationTests.swift`.)
struct WordishTests {

    @Test
    func testAppStartsInStartScreenState() {
        let vm = GameViewModel()
        #expect(vm.screenState == .start)
    }

    @Test
    func testTypingIncreasesColumn() {
        let vm = GameViewModel()
        vm.type("A")
        #expect(vm.currentCol == 1)
    }

    @Test
    func testBackspaceDecreasesColumn() {
        let vm = GameViewModel()
        vm.type("A")
        vm.backspace()
        #expect(vm.currentCol == 0)
    }
}
