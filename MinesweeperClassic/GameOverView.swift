//
//  GameOverView.swift
//  MinesweeperClassic
//
//  Created by Michael Fiedler on 27.05.25.
//

import SwiftUI
import Vortex

struct GameOverView: View {
    var gameState: GameState
    var squareCount: Int
    var secondsElapsed: Int
    var restart: () -> Void

    @State private var animateExplosion = false
    @State private var oldRecord = 0

    var body: some View {
        GeometryReader { context in
            ZStack {
                if gameState == .won {
                    VortexView(.fireworks) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.white)
                            .blur(radius: 3)
                            .blendMode(.plusLighter)
                            .frame(width: 32)
                            .tag("circle")
                    }
                }
                
                VStack(spacing: 10) {
                    Spacer()
                    Group {
                        if gameState == .won {
                            Text("You win!")
                                .textCase(.uppercase)
                                .font(.system(size: 40).weight(.black))
                            if oldRecord == 0 {
                                Text(
                                    "You set a new record for \(squareCount) Fields.\nYour record: \(secondsElapsed) seconds"
                                )
                                .font(.title)
                            } else if secondsElapsed < oldRecord {
                                Text(
                                    "You set a new record for \(squareCount) Fields.\nOld Time: \(oldRecord) seconds\nNew Time: \(secondsElapsed) seconds"
                                )
                                .font(.title)
                            } else {
                                Text(
                                    "Your current record for \(squareCount) Fields: \(oldRecord) seconds"
                                )
                                .font(.title)
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
                    .padding(.top)
                    
                    Spacer()
                }
            }
            .overlayStyle()
            .onAppear {
                if gameState == .won {
                    animateExplosion = true
                    oldRecord = getOldRecord(for: squareCount)
                    if oldRecord == 0 || secondsElapsed < oldRecord {
                        let record = RecordTime(
                            squareCount: squareCount,
                            newTime: secondsElapsed
                        )
                        do {
                            try saveNew(record: record, to: "records.json")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    GameOverView(gameState: .won, squareCount: 100, secondsElapsed: 50, restart: {})
}
