//
//  GameModels.swift
//  Wordish
//
//  Created by Lucas Lopez.
//

import Foundation
import SwiftUI

/// Shared constants used throughout the Wordish game.
nonisolated enum GameConstants {
    
    // MARK: - Game Rules
    static let wordLength = 5
    static let maxRows = 6
    
    // MARK: - Fallback Word
    /// Fallback secret word used when the API fails.
    static let fallbackWord = "APPLE"
    
    // MARK: - UI Layout
    static let tileSize: CGFloat = 44
    static let tileCornerRadius: CGFloat = 6
    static let keyboardEnterWidth: CGFloat = 70
    static let keyboardKeyWidth: CGFloat = 35
}

// MARK: - Games Result

/// Represents the final outcome of a finished game
enum GameResult: Equatable {
    case won
    case lost
}

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
    var tiles: [Tile] = (0..<GameConstants.wordLength).map { _ in Tile() }
}

// MARK: - Games Status

/// Represents whether the game is ongoing or finished (with associated result).
enum GameStatus: Equatable {
    case playing
    case finished(result: GameResult)
}

// MARK: - Unified UI Screen State

/// Represents the current UI screen the user should see.
/// Ensures the UI can only ever be in ONE valid state at a time.
enum GameScreenState {
    case start
    case loading
    case playing
    case finished(GameResult)
}
