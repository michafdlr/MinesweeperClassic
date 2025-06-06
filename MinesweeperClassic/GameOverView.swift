//
//  GameOverView.swift
//  MinesweeperClassic
//
//  Created by Michael Fiedler on 27.05.25.
//

import SwiftUI

struct GameOverView: View {
    var gameState: GameState
    var squareCount: Int
    var secondsElapsed: Int
    var restart: () -> Void
    
    var body: some View {
        let oldRecord = getOldRecord(for: squareCount)
        VStack(spacing: 10) {
            Group {
                if gameState == .won {
                    Text("You win!")
                        .textCase(.uppercase)
                        .font(.system(size: 40).weight(.black))
                    if oldRecord == 0 {
                        Text("You set a new record for \(squareCount) Fields.\nYour record: \(secondsElapsed) seconds")
                    } else if secondsElapsed < oldRecord {
                        Text("You set a new record for \(squareCount) Fields.\nOld Time: \(oldRecord) seconds\nNew Time: \(secondsElapsed) seconds")
                    }
                } else {
                    Text("You loose, better luck next time!")
                        .textCase(.uppercase)
                        .font(.system(size: 40).weight(.black))
                }
            }
            .foregroundStyle(.white)
            .fontDesign(.rounded)
            .multilineTextAlignment(.center)
            
            Button(action: restart) {
                Text("Try Again")
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .foregroundStyle(.white)
                    .background(.blue.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .font(.title)
            .buttonStyle(.plain)
        }
        .overlayStyle()
    }
}

#Preview {
    GameOverView(gameState: .won, squareCount: 100, secondsElapsed: 50, restart: {})
}
