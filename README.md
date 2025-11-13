# Wordish – iOS Word Guessing Game by Lucas Lopez
*A Wordle-inspired iOS game built with SwiftUI, async/await networking, and clean MVVM architecture.*

![iOS](https://img.shields.io/badge/iOS-17+-lightgrey)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Ready-blue)
![API](https://img.shields.io/badge/API-RandomWord-success)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-informational)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Demo  

<p align="center">
  <img src="Screenshots/demo.gif" width="350" alt="Wordish Demo" />
</p>

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

## Overview  
**Wordish** is an iOS word-guessing game inspired by *Wordle*, recreated entirely in **SwiftUI** with clean architecture, smooth animations, and real-time API-driven word generation.

---

## Features  

### Core Gameplay
- Guess the 5-letter word in 6 attempts  
- Tile color feedback (🟩 correct, 🟨 present, ⬜️ absent)  
- Dynamic on-screen keyboard with matching colors  
- Delete + Enter functionality  
- Win/Loss screen with solution reveal  

### UI & Interaction
- Smooth keypress animation  
- Color fade transitions  
- Intro splash screen  
- Loading overlay while fetching new words  

### API Integration
- Fetches random 5-letter words using:  
  `https://random-word-api.vercel.app/api?words=1&length=5`  
- Async/await word fetch with automatic fallback  

---

## Architecture

### MVVM Breakdown
| Layer | Role |
|-------|------|
| **Model** | Represents tiles, rows, and letter states |
| **ViewModel** | Game logic, evaluation, keyboard coloring, API calls |
| **Views** | Grid, keyboard, overlays, intro screen |

### Networking  
- `WordService` implemented as an **actor** for concurrency safety  
- Uses `URLSession` + `async/await`  
- Decodes API JSON array into uppercase secret word  

### Custom Views
- `KeyboardView` with dynamic rows & key state colors  
- `TileView` with configurable background color  
- Loading overlay using `ProgressView`  
- Intro screen with fade animation  

---

## Installation

### Requirements
- Xcode 15+  
- iOS 17+  
- Swift 5.9  

### Steps
1. Clone the repo
2. Open in Xcode
3. Run the Project
4. Don't forget to have fun! :)

---

## Project Structure
```bash
Wordish/
│
├── Models
│   ├── Tile.swift
│   ├── Row.swift
│   └── LetterState.swift
│
├── ViewModel
│   └── GameViewModel.swift
│
├── Services
│   └── WordService.swift
│
├── Views
│   ├── ContentView.swift
│   ├── KeyboardView.swift
│   └── TileView.swift
│
└── Assets
```

---

## Credits 
This project is a personal project inspired by Wordle.
- Wordle was originally created by *Josh Wardle*.
- It is now owned and published by *The New York Times Company*.

Wordish is not affiliated with, endorsed by, or connected to NYT or Wordle.
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
