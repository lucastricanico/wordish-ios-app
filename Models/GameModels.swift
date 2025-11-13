//
//  GameModels.swift
//  Wordish
//
//  Created by Lucas Lopez.
//

import Foundation // Basic Swift Types
import SwiftUI

// LetterState Represents the classification of a letter
enum LetterState: Equatable {
    case unknown // not evaluated yet
    case correct // right letter + right position = green
    case present // right word + wrong position = yellow
    case absent // wrong word + wrong position = grey
}

// A single tile in the grid (one character + its status)
struct Tile: Identifiable { // identifiable to assign id to each object
    let id = UUID()   // unique ID for each object
    var char: Character? = nil   // letter typed by the player, can be optional (?) and is set to nil
    var state: LetterState = .unknown // state set to unknown from enum LetterState
}

// A row of 5 tiles (one full guess)
struct Row: Identifiable {
    let id = UUID()
    var tiles: [Tile] = (0..<5).map { _ in Tile() }
}

// GamesStatus represents the status of the game
enum GameStatus {
    case playing // still guessing in game
    case won // won game
    case lost // lost game
}
