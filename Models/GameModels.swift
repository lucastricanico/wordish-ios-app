//
//  GameModels.swift
//  Wordish
//
//  Created by Lucas Lopez.
//

import Foundation
import SwiftUI

// MARK: - Letter Classification

/// Represents the evaluation state of a latter in a guess
///
/// State is used to color the tiles in a guess according to the secret word:
/// - `.unknown`: Letter has not been evaluated yet = dark gray
/// - `.correct`: Letter is in the correct position = green
/// - `.present`: Letter exists in the word but in a different position = yellow
/// - `.absent`: Letter is not in the word at all = gray
enum LetterState: Equatable {
    case unknown
    case correct
    case present
    case absent
}

// MARK: - Tile Model

/// A single tile in the grid.
///
/// Each tile represents one character the user typed and the tile’s current
/// evaluation state. Conforms to `Identifiable` so SwiftUI can track it in lists.
struct Tile: Identifiable {
    
    ///  Unique identifier so SwiftUI can diff & animate tiles.
    let id = UUID()
    
    /// The character typed by the user (optional because the tile starts empty).
    var char: Character? = nil
    
    /// The tile's evaluation state, defaults to `.unknown` before guessing.
    var state: LetterState = .unknown
}

// MARK: - Row Model

/// Represents a row in the grid (a single 5-letter guess).
///
/// A row contains exactly 5 `Tile` objects.
struct Row: Identifiable {
    
    /// Unique row identifier.
    let id = UUID()
    
    /// Array of 5 tiles initialized to empty.
    var tiles: [Tile] = (0..<5).map { _ in Tile() }
}

// MARK: - Game Status

/// Represents the current status of the game.
///
/// Used by the UI to show overlays like “Game Over” or “You Win”.
enum GameStatus {
    case playing /// Actively guessing
    case won /// Correct word guessed
    case lost /// Ran out of attempts
}
