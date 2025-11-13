//
//  GameViewModel.swift
//  Wordish
//
//  Created by Lucas Lopez.
//

import SwiftUI
import Combine

@MainActor // class runs on main thread = UI thread
final class GameViewModel: ObservableObject { // final to avoid subclasses = clearer

    // all rows in the game
    @Published var rows: [Row] = []

    // which row we are currently typing into, set to 0
    @Published var currentRow: Int = 0

    // which column we are currently typing into within row, set to 0
    @Published var currentCol: Int = 0

    // game status set to enum GameStatus = .playing
    @Published var status: GameStatus = .playing
    
    // secret word to be guessed
    @Published var secret: String = "APPLE"
    
    // dictionary
    @Published var keyStates: [Character: LetterState] = [:]
    
    // tells View if game is currently fetching a word or not, starts as false
    @Published var isLoading = false

    init() { // initialized when game runs, calls resetGrid()
        resetGrid()
    }

    // Reset the grid to 6 empty rows, empty columns, and status set initialized to .playing
    func resetGrid() {
        rows = (0..<6).map { _ in Row() }
        currentRow = 0
        currentCol = 0
        status = .playing
        keyStates.removeAll() // resets all keyStates (colors)
        
        isLoading = true // update isLoading to true
        
        // secret word from API
        Task {
                let service = WordService()
                do {
                    let newWord = try await service.fetchRandomWord() // calls async function // try = might throw if network fails
                    await MainActor.run { // await = suspends task until network finishes // ensures self.secret is updated back on main UI
                        self.secret = newWord
                        self.isLoading = false // hide the overlay
                        print("New secret word:", newWord)
                    }
                } catch {
                    await MainActor.run { // fall back to APPLE if there is an error with netwoek or API
                        self.secret = "APPLE"
                        self.isLoading = false // hide overlay
                        print("Failed to fetch word, defaulting to APPLE:", error)
                    }
                }
            }
        
    }

    func type(_ ch: Character) { // function that takes a single parameter = character typed
        // Don’t type if the game is over
        guard status == .playing else { return } // unless status is playing, we stop the typing

        // Make sure we have space in the current row
        guard currentRow < rows.count, // unless currentRow < total rows, we stop the typing
              currentCol < 5 else { return } // unless currentColumn < 5, we stop the typing

        // Write the letter into the Tile
        rows[currentRow].tiles[currentCol].char = ch //write character in current tile

        // Move to next column
        currentCol += 1
    }
    
    func backspace() { // function for backspace
          
            guard status == .playing else { return } // unless status is playing, stop backspaces

            // Make sure we are within row bounds
            guard currentRow < rows.count else { return } // unless within row bounds, stop backspaces

            guard currentCol > 0 else { return } // unless there is at least 1 char typed, stop backspaces

            // move cursor left
            currentCol -= 1

            // clear that tile
            rows[currentRow].tiles[currentCol].char = nil
        }
    
    func submit() { // function for submitting word
        // only if game is still playing
        guard status == .playing else { return } // unless status is playing, stop submission

        // must be exactly 5 letters to submit
        guard currentCol == 5 else { return } // unless in column 5, stop submission
        
        // guess string
        let guess = rows[currentRow].tiles // get 5 tile objects in current row
            .compactMap { $0.char } // pull out each character ignoring nils
            .map { String($0) } // turn each character into a string
            .joined() // join all string into one

            // evaluate guess
            evaluate(guess: guess)
        
        // guess condition
        if guess == secret { // if our guess = secret
            status = .won // change status of status to .won
            return
        }

        // if we've submitted the last row, game is over
        if currentRow == rows.count - 1 { // if in last row and we submitted, game is over = lost
            status = .lost
            return
        }

        // otherwise (have not lost), we move to next row
        currentRow += 1
        currentCol = 0
    }
    
    // evaluates the win
    private func evaluate(guess: String) {
        let secretArray = Array(secret) // convert to array to index
        let guessArray = Array(guess) // conver to array to index
        
        var states = Array(repeating: LetterState.absent, count: 5) // assume all tiles are gray
        
        var remainingCounts: [Character: Int] = [:] //count how many copies of X letter are unclaimed
        for ch in secretArray {
            remainingCounts[ch, default: 0] += 1 // counts how many unclaimed
        }
        
        // first loop that evaluates if letter in same position -> green
        for i in 0..<5 {
            if guessArray[i] == secretArray[i] { // if letter guesed in same position as array
                states[i] = .correct // set state to correct -> green
                remainingCounts[guessArray[i], default: 0] -= 1 // decrement count for that letter
            }
            
        }
        
        // second loop that skips indices that are already green and considers for yellow now
        for i in 0..<5 {
                guard states[i] != .correct else { continue } // if green we ignore, else continue
                let ch = guessArray[i]
                if let remaining = remainingCounts[ch], remaining > 0 { // if letter has remaining count
                    states[i] = .present // set state to present -> yellow
                    remainingCounts[ch] = remaining - 1 // decrement count for that letter
                } else {
                    states[i] = .absent // else (not present), we set state to absent -> grey
                }
            }
        
        // third loop that applies results of states to all tiles
        for i in 0..<5 {
            rows[currentRow].tiles[i].state = states[i]
        }
        
        // fourth loop that updates the state of each letter
        for i in 0..<5 {
            let ch = guessArray[i] // ch = letters of guess
            let newState = states[i] // newState = state of guessed letters

            // pick the better state if we already had one
            if let existing = keyStates[ch] {
                // hierarchy: correct > present > absent > unknown
                if newState == .correct || (newState == .present && existing == .absent) {
                    keyStates[ch] = newState
                }
            } else {
                keyStates[ch] = newState
            }
        }
    }
    
}
