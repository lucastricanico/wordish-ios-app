//
//  KeyboardView.swift
//  Wordish
//
//  Created by Lucas Lopez.
//

import SwiftUI

struct KeyboardView: View {
    @ObservedObject var vm: GameViewModel // view depends on existing ViewModel instance = uses same vm as ContentView
    
    @State private var pressedKey: String? = nil // keyboard can remember which key is being pressed, local transient state
    
    // arrays of key labes
    private let row1 = ["Q","W","E","R","T","Y","U","I","O","P"]
    private let row2 = ["A","S","D","F","G","H","J","K","L"]
    private let row3 = ["Enter","Z","X","C","V","B","N","M","⌫"]
    
    // loops through each array
    var body: some View {
        VStack(spacing: 6) { // stacks the rows vertically
            keyboardRow(row1)
            keyboardRow(row2)
            keyboardRow(row3)
        }
        .padding(.top, 10)
    }

    // function that sets up the keyboard in UI
    @ViewBuilder // allows function to return multiple nested views
    private func keyboardRow(_ letters: [String]) -> some View {
        HStack(spacing: 4) { // places keys horizontally
            // loops through array of key labels
            ForEach(letters, id: \.self) { key in // use each value for its id
                Button(action: { handleKeyPress(key) }) { // set up a button for each key
                    Text(key) // button contains key value
                        .font(.headline)
                        .frame(width: keyWidth(for: key), height: 50)
                        .background(colorForKey(key)) // update key to color according to secret word
                        .animation(.easeInOut(duration: 0.2), value: vm.keyStates) // animate color to smoothly transition when keyStates changes value
                        .scaleEffect(isPressed(key) ? 0.92 : 1.0) // scales view's size
                        .animation(.easeInOut(duration: 0.1), value: pressedKey) // when pressedKey changes value, smoothly animate .scaleEffect
                        .cornerRadius(6)
                }
            }
        }
    }
    
    // function that establishes width for long keys (enter and backspace)
    private func keyWidth(for key: String) -> CGFloat {
        switch key {
        case "Enter", "⌫": return 70
        default: return 35
        }
    }
    
    // function that decides what to do when each key is tapped
    private func handleKeyPress(_ key: String) {
        pressedKey = key // set pressedKey to the label in the key pressed
        
        // wait 0.1 seconds and set ketPressed back to nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
               pressedKey = nil
           }
        
        switch key { // use a Switch
        case "⌫": // when backspace -> call function backspace()
            vm.backspace()
        case "Enter": // when enter -> call function submit()
            vm.submit()
        default: // when another key (letters) -> call function type()
            if let ch = key.first {
                vm.type(ch)
            }
        }
    }
    
    // function that determines if key is pressed, returns boolean
    private func isPressed(_ key: String) -> Bool {
        return pressedKey == key // if pressed, set presedKey = ket label
    }
    
    // function that returns the color that should be assigned to key based on the letters in the secret word
    private func colorForKey(_ key: String) -> Color { // takes key label text
        guard key.count == 1, let ch = key.first else { // ensures key is the only character
            return Color.secondary.opacity(0.15) // Enter & ⌫ stay neutral
        }

        // once we know we have a real character
        switch vm.keyStates[ch] { // switch to look in keyStates dic
        case .correct: return .green // if correct => green
        case .present: return .yellow // if present => yellow
        case .absent:  return .gray // if absent => gray
        default:       return Color.secondary.opacity(0.15) // else => no change
        }
    }
}

#Preview {
    KeyboardView(vm: GameViewModel())
}
