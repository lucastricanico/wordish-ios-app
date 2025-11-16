//
//  ContentView.swift
//  Wordish
//
//  Created by Lucas Lopez.
//

import SwiftUI



/// The main game screen for Wordish.
/// Displays the title, tile grid, custom keyboard, loading overlay,
/// game-end overlay, and an animated start screen.
/// This view owns the `GameViewModel` and reacts to its published state.
struct ContentView: View {
    
    /// Controls visibility of the initial splash/start screen.
    @State private var showStartScreen = true
    
    /// The game’s primary state container.
    /// `@StateObject` ensures the ViewModel lives as long as the view.
    @State private var vm = GameViewModel()
    
    var body: some View { // standard SwiftUI view model
        ZStack {
            
            // MARK: - Main Game UI (Grid + Keyboard)
            VStack(spacing: 12) { // stacks childviews (grid and tiles)
                Text("WORDISH")
                    .font(.largeTitle)
                    .bold()
                
                gridView                // Game board
                KeyboardView(vm: vm)    // Custom keyboard view
                
            }
            .padding() //adds default padding around VStack
            
            // MARK: - Loading Overlay
            if vm.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                ProgressView("Fetching word...")
                    .font(.title3)
                    .padding()
                    .foregroundColor(.white)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
            
            // MARK: - Win/Loss Overlay
            if case .finished(let result) = vm.status {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 8) {
                    switch result {
                    case .won:
                        Text("You Win!")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                    
                    case .lost:
                        Text("Game Over!")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        Text("Answer: \(vm.secret)")
                            .foregroundColor(.white)
                    }
                    
                    Button("New Game") {
                        vm.resetGrid()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
            
            // MARK: - Start Screen Overlay
            if showStartScreen {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("WORDISH")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("by Lucas Lopez")
                        .font(.title3)
                        .foregroundColor(.black.opacity(0.8))
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showStartScreen = false
                        }
                    }) {
                        Text("Start Game")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
    
    // MARK: - Grid View
    /// Builds the 6×5 grid of tiles.
    private var gridView: some View {
        VStack(spacing: 8) { // vertically stacks rows
            ForEach(vm.rows) { row in // loops through rows
                HStack(spacing: 8) { // horizontally stacks tiles
                    ForEach(row.tiles) { tile in // loops over tiles
                        tileView(tile) // renders each tile
                    }
                }
            }
        }
    }
    
    /// Builds a single tile view from a `Tile` model.
    @ViewBuilder // lets function return multiple child views
    private func tileView(_ tile: Tile) -> some View { // helper that takes Tile and returns View
        ZStack { // layers views on top of each other
            RoundedRectangle(cornerRadius: GameConstants.tileCornerRadius) // draws second rectangle that is the background fill
                .fill(color(for: tile.state)) // set background fill to the state of the tile
            RoundedRectangle(cornerRadius: GameConstants.tileCornerRadius) // draws rectangle
                .stroke(Color.gray, lineWidth: 1)
            
            Text(tile.char.map { String($0) } ?? "") // character if present or empty if not
                .font(.title2)
                .bold()
        }
        .frame(width: GameConstants.tileSize, height: GameConstants.tileSize) // controls square size
    }
    
    /// Returns the background color for a tile based on its evaluation state.
    private func color(for state: LetterState) -> Color {
        switch state {
        case .unknown: return Color.clear // if state is .unknown -> no color
        case .correct: return .green // if state is correct -> green
        case .present: return .yellow // if state is present -> yellow
        case .absent:  return .gray // if state is absent -> gray
        }
    }
}

#Preview {
    ContentView()
}
