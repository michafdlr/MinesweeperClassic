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
            if square.hasMine {
                return Color.red.opacity(0.3)
            } else {
                return Color.gray.opacity(0.3)
            }
        } else {
            return Color.gray
        }
    }

    var body: some View {
        ZStack {
//            ForEach(0..<25) { _ in
//                Rectangle()
//                    .rotation(Angle(degrees: Double.random(in: 0..<360)))
//                    .fill(.gray.gradient)
//                    .scaleEffect(square.isRevealed ? 1 : 0)
//                    .frame(width: size/4, height: size/4)
//                    .offset(x: square.isRevealed ? CGFloat.random(in: -1...1)*200 : 0, y: square.isRevealed ? CGFloat.random(in: -1...1)*200 : 0)
//                    .opacity(square.isRevealed ? 0 : 1)
//                    .animation(.easeInOut(duration: 0.8), value: square.isRevealed)
//            }
            
            Group {
                Rectangle()
                        .fill(color.gradient)
                
                if square.isRevealed {
                    if square.hasMine {
                        Text("💥")
                            .font(size > 35 ? .title : .callout)
                            .shadow(color: .red, radius: 1)
                    } else if square.nearbyMines > 0 {
                        switch square.nearbyMines {
                        case 1:
                            Text("\(square.nearbyMines)")
                                .font(size > 35 ? .title : .callout)
                                .foregroundStyle(.green)
                        case 2:
                            Text("\(square.nearbyMines)")
                                .font(size > 35 ? .title : .callout)
                                .foregroundStyle(.yellow)
                        case 3:
                            Text("\(square.nearbyMines)")
                                .font(size > 35 ? .title : .callout)
                                .foregroundStyle(.orange)
                        default:
                            Text("\(square.nearbyMines)")
                                .font(size > 35 ? .title : .callout)
                                .foregroundStyle(.red)
                        }
                    }
                } else if square.isFlagged {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(size > 35 ? .title : .callout)
                        .foregroundStyle(.black, .yellow)
                        .shadow(color: .black, radius: 3)
                }
            }
            .rotationEffect(.degrees(square.isRevealed ? 360 : 0))
            .animation(.easeInOut(duration: 0.5), value: square.isRevealed)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    let square = Square(row: 0, col: 0)
    square.isFlagged = true
    return SquareView(square: square, size: 33.0)
        .padding(50)
}
