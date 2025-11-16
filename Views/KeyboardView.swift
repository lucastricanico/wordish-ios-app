//
//  KeyboardView.swift
//  Wordish
//
//  Created by Lucas Lopez.
//

import SwiftUI
import Observation

/// A fully custom on-screen keyboard.
///
/// ### Why did I use a custom keyboard?
/// While SwiftUI’s default `TextField` automatically shows the system keyboard,
/// my game's keyboard only allows **A–Z letters, Enter, and Delete**.
///
/// I also wanted the format to be different than the default keyboard.
///
/// My custom keyboard:
/// - ensures only valid input is allowed
/// - provides full control over colors & animations (super useful in this scenario)
/// - avoids the system keyboard covering UI elements
///
struct KeyboardView: View {
    /// Shared game state (letters typed, key colors, submission, etc.)
    @Bindable var vm: GameViewModel
    
    /// Tracks which key is currently being tapped, purely for animation.
    @State private var pressedKey: String? = nil
    
    // MARK: - Keyboard Layout
    
    /// QWERTY keyboard grouped into the 3 standard Wordle-style rows.
    private let row1 = ["Q","W","E","R","T","Y","U","I","O","P"]
    private let row2 = ["A","S","D","F","G","H","J","K","L"]
    private let row3 = ["Enter","Z","X","C","V","B","N","M","⌫"]
    
    // MARK: - Body
    
    /// Builds the vertical stack of 3 keyboard rows.
    var body: some View {
        VStack(spacing: 6) {
            keyboardRow(row1)
            keyboardRow(row2)
            keyboardRow(row3)
        }
        .padding(.top, 10)
    }
    
    // MARK: - Row Builder
    
    /// Builds a row of keyboard keys from an array of labels.
    ///
    /// `@ViewBuilder` allows returning multiple nested views.
    @ViewBuilder
    private func keyboardRow(_ letters: [String]) -> some View {
        HStack(spacing: 4) {
            ForEach(letters, id: \.self) { key in
                Button(action: { handleKeyPress(key) }) {
                    Text(key)
                        .font(.headline)
                        .frame(width: keyWidth(for: key), height: 50)
                        .background(colorForKey(key))
                        .animation(.easeInOut(duration: 0.2), value: vm.keyStates)
                        .scaleEffect(isPressed(key) ? 0.92 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: pressedKey)
                        .cornerRadius(6)
                }
            }
        }
    }
    
    // MARK: - Key Handling
        
    /// Determines width of each key.
    /// Larger width for Enter and Backspace for usability.
    private func keyWidth(for key: String) -> CGFloat {
        switch key {
        case "Enter", "⌫": return GameConstants.keyboardEnterWidth
        default: return GameConstants.keyboardKeyWidth
        }
    }
    
    /// Handles all key presses from the keyboard, including:
    /// - Character input
    /// - Submission
    /// - Backspace
    ///
    /// Also applies short animations by temporarily setting `pressedKey`.
    private func handleKeyPress(_ key: String) {
        pressedKey = key
        
        // Clear animated key highlight shortly after tapping
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
               pressedKey = nil
           }
        
        switch key {
        case "⌫":
            vm.backspace()
        case "Enter":
            vm.submit()
        default:
            if let ch = key.first {
                vm.type(ch)
            }
        }
    }
    
    /// Returns true if this key is currently the animated "pressed" key.
    private func isPressed(_ key: String) -> Bool {
        return pressedKey == key
    }
    
    // MARK: - Key Coloring (Game Feedback)
        
    /// Determines a key’s background color based on its evaluation state.
    ///
    /// - Green: correct letter + correct position
    /// - Yellow: correct letter + wrong position
    /// - Gray: letter not in the secret word
    ///
    /// Non-letter keys (Enter, bakspace) stay neutral.
    private func colorForKey(_ key: String) -> Color {
        guard key.count == 1, let ch = key.first else {
            return Color.secondary.opacity(0.15)
        }

        switch vm.keyStates[ch] {
        case .correct: return .green
        case .present: return .yellow
        case .absent:  return .gray
        default:       return Color.secondary.opacity(0.15)
        }
    }
}

#Preview {
    KeyboardView(vm: GameViewModel())
}
