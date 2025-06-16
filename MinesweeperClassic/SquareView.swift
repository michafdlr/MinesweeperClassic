//
//  SquareView.swift
//  MinesweeperClassic
//
//  Created by Michael Fiedler on 25.05.25.
//

import SwiftUI

struct SquareView: View {
    let square: Square
    var size: CGFloat

    var color: Color {
        if square.isRevealed {
            if square.hasMine && !square.isFlagged {
                return Color.red.opacity(0.4)
            } else if square.hasMine && square.isFlagged {
                return Color.green.opacity(0.4)
            } else {
                return Color.gray.opacity(0.4)
            }
        } else if square.isFlagged {
            return Color.yellow.opacity(0.8)
        } else {
            return Color.gray
        }
    }

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Group {
                    Rectangle()
                        .fill(color.gradient)

                    if square.isRevealed {
                        if square.hasMine {
                            Image("mine")
                                .resizable()
                                .scaledToFit()
//                                .shadow(color: .yellow, radius: 2)
                                .rotationEffect(Angle(degrees: 180))
                                .rotation3DEffect(
                                    Angle(degrees: 180),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                        } else if square.nearbyMines > 0 {
                            Text("\(square.nearbyMines)")
                                .font(.system(size: proxy.size.width * 0.5))
                                .foregroundStyle(getColorForMines(square.nearbyMines))
                                .rotationEffect(Angle(degrees: 180))
                                .rotation3DEffect(
                                    Angle(degrees: 180),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                        }
                    } else if square.isFlagged {
                        Image(systemName: "flag.fill")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(0.5)
                            .foregroundStyle(.red)
                            .shadow(color: .black, radius: 3)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            }
        }
        .frame(width: size, height: size)
        .rotation3DEffect(
            .degrees(square.isRevealed ? 180 : 0),
            axis: (x: 1, y: 0, z: 0)
        )
        .animation(.easeInOut(duration: 0.5), value: square.isRevealed)
    }

    func getColorForMines(_ count: Int) -> Color {
        switch count {
        case 1: return .green
        case 2: return .yellow
        case 3: return .orange
        default: return .red
        }
    }
}

#Preview {
    let square = Square(row: 0, col: 0)
    square.isFlagged = true
    square.isRevealed = true
    square.hasMine = true
    return SquareView(square: square, size: 33.0)
        .scaleEffect(2)
        .padding(50)
}
