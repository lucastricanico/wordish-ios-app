# Wordish – iOS Word Guessing Game 
*by Lucas Lopez*

*A Wordle-inspired iOS game built with SwiftUI, async/await networking, and clean MVVM architecture.*

<p align="left">

  <img src="https://img.shields.io/badge/iOS-17+-lightgrey?style=for-the-badge" />
  <img src="https://img.shields.io/badge/SwiftUI-Ready-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Swift_Concurrency-async%2Fawait-yellow?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Architecture-MVVM_+_Observable-informational?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Unit_Tests-Included-brightgreen?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" />


</p>

---

## Demo  

<p align="center">
  <img src="Screenshots/demo.gif" width="350" alt="Wordish Demo" />
</p>

---

## Overview  
**Wordish** is a Wordle-style word-guessing game redesigned from the ground up using modern iOS development patterns:
- SwiftUI first
- Swift Concurrency (async/await)
- @Observable + @MainActor ViewModel
- Actor-isolated networking
- Fully custom keyboard UI
- Unit tests for the core evaluation algorithm

---

## Tech Stack

<p align="left">

  <img src="https://img.shields.io/badge/Swift-FA7343?logo=swift&logoColor=white&style=for-the-badge" />
  <img src="https://img.shields.io/badge/SwiftUI-0A84FF?logo=swift&logoColor=white&style=for-the-badge" />
  <img src="https://img.shields.io/badge/@Observable-New_Observation_Framework-pink?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Concurrency-Actors_%7C_MainActor-yellow?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Networking-URLSession-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Tests-Unit_Tests-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/API-Random_Word_API-success?style=for-the-badge" />

</p>

---

## Features  

### Core Gameplay
- Guess the 5-letter word in 6 attempts  
- Tile color feedback (🟩 correct, 🟨 present, ⬜️ absent)  
- Duplicate letter-safe evaluation algorithm
- Dynamic on-screen keyboard with matching colors  
- Delete + Enter functionality  
- Win/Loss screen with solution reveal  

### UI & Interaction
- Smooth keypress animation  
- Color fade transitions  
- Intro splash screen  
- Loading overlay while fetching new words
- Custom animated start screen to introduce the game

### API Integration
- Fetches random 5-letter words using:  
  `https://random-word-api.vercel.app/api?words=1&length=5`  
- Safe async/await word fetch with automatic fallback  

---

## Screenshots  

<p align="center">
  <img src="Screenshots/start_screen.png" width="280" alt="Start Screen" />
  <img src="Screenshots/game_screen.png" width="280" alt="Game Screen" />
</p>

<p align="center">
  <em>Left: Start Game screen | Right: Gameplay screen</em>
</p>

---

## Architecture

Wordish follows a modern **MVVM architecture** tailored for SwiftUI and Swift Concurrency.  
The goal is to keep views simple, centralize logic in the ViewModel, and ensure all state updates are safe, predictable, and testable.

---

### MVVM Overview

| Layer | Responsibility |
|-------|---------------|
| **Model** | Defines basic game structures (tiles, rows, states, constants) with no logic. |
| **ViewModel (`GameViewModel`)** | Contains all game logic, guess evaluation, async word loading, and screen-state transitions. |
| **Views** | SwiftUI layouts (grid, keyboard, overlays) that react automatically to ViewModel changes. |

---

### 1. Models

The model layer defines only data, not behavior:

- `Tile` — letter + evaluation state  
- `Row` — a single 5-letter guess  
- `LetterState` — correct / present / absent / unknown  
- `GameStatus` & `GameResult` — playing / won / lost  
- `GameScreenState` — start / loading / playing / finished  
- `GameConstants` — shared layout + game rule values  

All logic lives in the ViewModel, not in these models.

---

### 2. ViewModel (`GameViewModel`)

The ViewModel is annotated with:

- `@Observable` for SwiftUI-native reactivity  
- `@MainActor` to ensure UI-safe state updates  

Its responsibilities include:

#### **Game Logic**
- Managing the 6×5 grid  
- Typing, deleting, and submitting guesses  
- Two-pass evaluation algorithm (duplicate-letter safe)  
- Updating keyboard colors based on best-known info  

#### **App State**
Uses **`GameScreenState`** to control UI flow:
- `.start`  
- `.loading`  
- `.playing`  
- `.finished(GameResult)`  

This design guarantees the UI is always in exactly one valid state.

#### **Networking**
- Fetches random words using `WordService`  
- Runs asynchronously using async/await  
- Provides a fallback word on failure  
- Switches UI state from `.loading` → `.playing`  

#### **Testability**
The evaluation method is directly testable and covered by a full test suite.

---

### 3. Views

SwiftUI views remain intentionally “dumb”:

#### **ContentView**
- Owns the ViewModel  
- Displays grid, keyboard, and overlays  
- Switches layouts based on `screenState`

#### **KeyboardView**
- Custom Wordle-style keyboard  
- Keypress animation + color updates  
- Sends input events back to the ViewModel

#### **Tile Rendering**
- RoundedRectangle tiles sized by `GameConstants`  
- Colors driven entirely by `LetterState`

#### **Overlays**
- Start screen (animated fade-out)  
- Loading screen  
- Game end screen (won/lost + answer)

---

### 4. Networking (`WordService`)

Implemented as an `actor` for thread-safe concurrency:

- Uses `URLSession` + async/await  
- Decodes API response (`[String]`)  
- Returns a single uppercase word  
- Guarantees safe access even under parallel calls

---

### 5. Unit Testing

Evaluation logic is fully unit-tested, covering:

- Perfect match  
- All wrong  
- Present letters  
- Duplicate letter edge cases  

---

## Unit Testing
A dedicated **EvaluationTests.swift** suite validates correctness of guess evaluation logic.

### Covered Cases:
- Perfect match
- All letters wrong
- Letters present in wrong positions
- Duplicate letters

### Example Test

```bash
func testDuplicateLetters() {
    let states = evaluate("COCOA", secret: "CARGO")
    let expected: [LetterState] = [.correct, .absent, .absent, .present, .absent]
    XCTAssertEqual(states, expected)
}
```
--- 

## Installation

### Requirements
- Xcode 15+  
- iOS 17+  
- Swift 5.9  

### Steps
1. Clone the repo
    ```bash
    git clone https://github.com/lucastricanico/wordish-ios-app.git
    ```
2. Open in Xcode
3. Run the Project
4. Don't forget to have fun! :)

---

## Project Structure
```bash
Wordish/
│
├── Models/
│   └── GameModels.swift
│
├── ViewModels/
│   └── GameViewModel.swift
│
├── Services/
│   └── WordService.swift
│
├── Views/
│   ├── ContentView.swift
│   └── KeyboardView.swift
│
├── Tests/
│   └── EvaluationTests.swift
│
├── Screenshots/
│   ├── demo.gif
│   ├── start_screen.png
│   └── game_screen.png
│
├── Wordish/
│   ├── Assets.xcassets
│   └── WordishApp.swift
│
├── Wordish.xcodeproj
│
├── README.md
├── LICENSE
└── .gitignore
```

---

## Credits 
This project is a personal project inspired by Wordle.
- Wordle was originally created by *Josh Wardle*.
- It is now owned and published by *The New York Times Company*.

Wordish is an independent project and is not affiliated with, endorsed by, or associated with The New York Times or the official Wordle product.
This project is non-commercial and built for learning + portfolio purposes.

---

## Future Improvements
### Gameplay
- Tile flip animation (like Wordle)
- Shake animation for invalid words
- Real dictionary validation

### UX Enhancements
- Haptic feedback
- Dark mode
- Success/Failure animations

### Stats & Meta
- Guess distribution
- Win streak
- Shareable result grid

---

## License
Released under the MIT License.

See LICENSE for details.
