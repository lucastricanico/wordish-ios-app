//
//  ContentView.swift
//  Wordish
//
//  Created by Lucas Lopez.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showStartScreen = true

    @StateObject private var vm = GameViewModel() //view owns GameViewModel()

    var body: some View { // standard SwiftUI view model
        ZStack {
            
            // layers view on top of each other
        VStack(spacing: 12) { // stacks childviews (grid and tiles)
                Text("WORDISH")
                    .font(.largeTitle)
                    .bold()
                
                // The grid
                gridView // inserts another view = gridView
                
            KeyboardView(vm: vm) // include KeyBoardView view here
            
            }
            .padding() //adds default padding around VStack
            
            // overlay only shown when game is loading API word
            if vm.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                ProgressView("Fetching word...") // loading spinner from SwiftUI
                    .font(.title3)
                    .padding()
                    .foregroundColor(.white)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
            
            // overlay only shown when game lost or won (!= playing)
            if vm.status != .playing {
                        Color.black.opacity(0.4) // semi-transparent background
                            .ignoresSafeArea() // makes dimming trascend bound of overlay

                        VStack(spacing: 8) { // shows message text and New Game button
                            if vm.status == .won { // if won
                                Text("You Win!")
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(.white)
                            } else if vm.status == .lost { // if lost
                                Text("Game Over!")
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(.white)
                                Text("Answer: \(vm.secret)") // secret word
                                    .foregroundColor(.white)
                            }

                            Button("New Game") { // button for new game
                                vm.resetGrid() // calls resetGrid
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .background(.ultraThinMaterial) // froested glass effect
                        .cornerRadius(12)
                    }
            
            // start screen overlay
            if showStartScreen {
                Color.white.ignoresSafeArea() // color of background = white

                VStack(spacing: 20) { // stack content vertically
                    Text("WORDISH") // title
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.black)

                    Text("by Lucas Lopez") // caption
                        .font(.title3)
                        .foregroundColor(.black.opacity(0.8))

                    Button(action: { //button to start game
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showStartScreen = false // removes start screen
                        }
                    }) {
                        Text("Start Game") // text in button = start game
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

    // Grid
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

    // Tile
    @ViewBuilder // lets function return multiple child views
    private func tileView(_ tile: Tile) -> some View { // helper that takes Tile and returns View
        ZStack { // layers views on top of each other
            RoundedRectangle(cornerRadius: 6) // draws second rectangle that is the background fill
                .fill(color(for: tile.state)) // set background fill to the state of the tile
            RoundedRectangle(cornerRadius: 6) // draws rectangle
                .stroke(Color.gray, lineWidth: 1)

            Text(tile.char.map { String($0) } ?? "") // character if present or empty if not
                .font(.title2)
                .bold()
        }
        .frame(width: 44, height: 44) // controls square size
    }
    
    // function that determines the color of tiles based on the state
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
