//
//  GameViewModel.swift
//  Wordish
//
//  Created by Lucas Lopez.
//

import SwiftUI
import Observation

/// The main state manager for the Wordish game.
///
/// `GameViewModel` owns all gameplay state:
/// - the tile grid (rows/columns)
/// - current cursor position
/// - keyboard letter coloring
/// - game status (playing / won / lost)
/// - async loading of new secret words
///
/// This object is observable by SwiftUI, so all UI updates occur automatically
/// when published properties change.
@MainActor
@Observable
final class GameViewModel { // final to avoid subclasses = clearer
    
    // MARK: - Published Game State
    
    /// The 6 rows shown on screen. Each row contains 5 tiles.
    var rows: [Row] = []
    
    /// The index of the row the user is currently typing into.
    var currentRow: Int = 0
    
    /// The column position (0–4) inside the current row.
    var currentCol: Int = 0
    
    /// Whether the game is active, won, or lost.
    var status: GameStatus = .playing
    
    /// The secret 5-letter word the user needs to guess
    var secret: String = GameConstants.fallbackWord
    
    /// Tracks the best-known state for each keyboard letter.
    /// Used to color keys as `.correct`, `.present`, or `.absent`.
    var keyStates: [Character: LetterState] = [:]
    
    /// Whether the app is currently fetching a word from the API.
    var isLoading = false
    
    // MARK: - Initialization
    
    /// Sets up the game by creating an empty grid and fetching a new secret word.
    init() {
        resetGrid()
    }
    
    // MARK: - Game Setup
    
    /// Resets all gameplay state and asynchronously fetches a new secret word.
    ///
    /// This method:
    /// - clears the grid
    /// - resets cursor position
    /// - resets key states
    /// - sets game status back to `.playing`
    /// - shows a loading overlay
    /// - fetches a fresh word using `WordService`
    ///
    /// Uses Swift Concurrency (`async/await`) ensuring the UI remains responsive
    /// while the network request is in progress.
    
    func resetGrid() {
        rows = (0..<GameConstants.maxRows).map { _ in Row() }
        currentRow = 0
        currentCol = 0
        status = .playing
        keyStates.removeAll()
        
        isLoading = true
        
        Task {
            let service = WordService()
            let newWord: String
            do {
                // Suspends until the network request completes.
                newWord = try await service.fetchRandomWord()
            }
            catch {
                newWord = GameConstants.fallbackWord
                print("Failed to fetch word, defaulting to \(GameConstants.fallbackWord):", error)
            }
            await MainActor.run {
                self.secret = newWord
                self.isLoading = false
                
            }
        }
        
    }
    
    // MARK: - Input Handling
    
    /// Inserts a typed character into the current tile and advances the cursor.
    ///
    /// Ignores input if:
    /// - the game is already finished
    /// - the row is full
    func type(_ ch: Character) {
        guard status == .playing else { return }
        guard currentRow < rows.count,
              currentCol < GameConstants.wordLength else { return }
        
        rows[currentRow].tiles[currentCol].char = ch
        currentCol += 1
    }
    
    /// Deletes the character at the current cursor position.
    ///
    /// Behaves like a backspace:
    /// - moves cursor left
    /// - clears the tile
    func backspace() {
        
        guard status == .playing else { return }
        guard currentRow < rows.count else { return }
        guard currentCol > 0 else { return }
        
        currentCol -= 1
        rows[currentRow].tiles[currentCol].char = nil
    }
    
    // MARK: - Submission
    
    /// Validates and submits the current 5-letter guess.
    ///
    /// This method:
    /// - builds the guess string
    /// - evaluates tile states (green/yellow/gray)
    /// - updates keyboard letter states
    /// - determines win/loss conditions
    func submit() {
        guard status == .playing else { return }
        guard currentCol == GameConstants.wordLength else { return }
        
        let guess = rows[currentRow].tiles
            .compactMap { $0.char }
            .map { String($0) }
            .joined()
        
        evaluate(guess: guess)
        
        if guess == secret {
            status = .finished(result: .won)
            return
        }
        
        if currentRow == rows.count - 1 {
            status = .finished(result: .lost)
            return
        }
        
        currentRow += 1
        currentCol = 0
    }
    
    // MARK: - Evaluation
    
    /// Evaluates a submitted guess and updates tile + keyboard coloring.
    ///
    /// Uses a two-pass algorithm:
    /// 1. First marks correct letters (green)
    /// 2. Then marks present letters (yellow) based on remaining unmatched counts
    ///
    /// This prevents incorrectly over-highlighting duplicate letters.
    private func evaluate(guess: String) {
        let secretArray = Array(secret)
        let guessArray = Array(guess)
        
        var states = Array(repeating: LetterState.absent, count: 5)
        
        // Count remaining unmatched characters in the secret word
        var remainingCounts: [Character: Int] = [:]
        for ch in secretArray {
            remainingCounts[ch, default: 0] += 1
        }
        
        // Pass 1 — mark greens
        for i in 0..<GameConstants.wordLength {
            if guessArray[i] == secretArray[i] {
                states[i] = .correct
                remainingCounts[guessArray[i], default: 0] -= 1
            }
        }
        
        // Pass 2 — mark yellows
        for i in 0..<GameConstants.wordLength {
            guard states[i] != .correct else { continue }
            let ch = guessArray[i]
            if let remaining = remainingCounts[ch], remaining > 0 {
                states[i] = .present
                remainingCounts[ch] = remaining - 1
            } else {
                states[i] = .absent
            }
        }
        
        // Apply tile states
        for i in 0..<GameConstants.wordLength {
            rows[currentRow].tiles[i].state = states[i]
        }
        
        // Update keyboard states using best-known information
        for i in 0..<GameConstants.wordLength {
            let ch = guessArray[i]
            let newState = states[i]
            
            if let existing = keyStates[ch] {
                // Correct overrides everything
                // Present overrides absent
                if newState == .correct || (newState == .present && existing == .absent) {
                    keyStates[ch] = newState
                }
            } else {
                keyStates[ch] = newState
            }
        }
    }
    
}
