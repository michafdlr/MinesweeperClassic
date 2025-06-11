//
//  ContentView.swift
//  MinesweeperClassic
//
//  Created by Michael Fiedler on 25.05.25.
//

import SwiftUI
import Vortex

enum GameState {
    case setting, waiting, playing, won, lost
}

struct ContentView: View {
    @State private var rows = [[Square]]()
    @State private var rowCount = 10
    @State private var colCount = 10
    @State private var gameState = GameState.setting
    @State private var secondsElapsed = 0
    @State private var isHoveringRestart = false
    @State private var isHoveringInfo = false
    @State private var timer = Timer.publish(
        every: 1,
        tolerance: 0.1,
        on: .main,
        in: .common
    ).autoconnect()
    @State private var frameWidth = 600.0
    @State private var frameHeight = 600.0
    @State private var squareSize = 60.0
    @State private var lifesLeft = 3

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    HStack {
                        Text(minesLeft, format: .number.precision(.integerLength(3)))
                            .fixedSize()
                            .padding(.horizontal, 6)
                            .foregroundStyle(.red.gradient)
                            .font(.custom("Courier", size: 30))

                        Button(action: reset) {
                            HStack {
                                Text(statusEmoji)
                                Text("Restart")
                                    .font(.custom("Courier", size: 20))
                            }
                            .padding(5)
                            .frame(width: 150)
                            .background(.gray.gradient.opacity(0.5))
                            .clipShape(.rect(cornerRadius: 6))
                        }
                        .onHover { isHoveringRestart = $0 }
                        .buttonStyle(.plain)

                        Text(secondsElapsed, format: .number.precision(.integerLength(3)))
                            .fixedSize()
                            .padding(.horizontal, 6)
                            .foregroundStyle(.red.gradient)
                            .font(.custom("Courier", size: 30))
                            .onReceive(timer) { _ in
                                if gameState == .playing && secondsElapsed < 999 {
                                    secondsElapsed += 1
                                }
                            }
                    }
                    .monospaced()
                    .background(.black)
                    .clipShape(.rect(cornerRadius: 10))

                    HStack(spacing: 0) {
                        ForEach(1..<4, id: \.self) { i in
                            Image(systemName: "heart.fill")
                                .foregroundStyle(i <= lifesLeft ? .red : .gray)
                                .font(.largeTitle)
                                .animation(
                                    .linear(duration: 0.5).repeatCount(
                                        7,
                                        autoreverses: true
                                    ),
                                    value: lifesLeft
                                )
                        }
                    }

                    Image(systemName: "info.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.gray.opacity(0.8))
                        .padding(.leading, 10)
                        .onHover { bool in
                            withAnimation(.spring(duration: 0.5)) {
                                isHoveringInfo = bool
                            }
                        }
                        .onTapGesture {
                            #if os(iOS)
                            withAnimation(.spring(duration: 0.5)) {
                                isHoveringInfo.toggle()
                            }
                            #endif
                        }
                }
                .padding([.top, .horizontal], 5)

                Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                    ForEach(0..<rows.count, id: \.self) { row in
                        GridRow {
                            ForEach(rows[row]) { square in
                                SquareView(square: square, size: squareSize)
                                    .onLongPressGesture {
                                        flag(square)
                                    }
                                    .onTapGesture {
                                        select(square)
                                    }
                            }
                        }
                    }
                }
                .font(.largeTitle)
                .preferredColorScheme(.dark)
                .clipShape(.rect(cornerRadius: 6))
                .padding([.horizontal, .bottom], 5)
                .transition(.scale(scale: 2).combined(with: .opacity))
                .onAppear {
                    createGrid()
                }
            }
            .opacity(gameState == .playing || gameState == .waiting ? 1.0 : 0.5)
            .disabled(gameState == .setting || gameState == .won || gameState == .lost)

            if gameState == .won || gameState == .lost {
                GameOverView(
                    gameState: gameState,
                    squareCount: allSquares.count,
                    secondsElapsed: secondsElapsed
                ) {
                    withAnimation {
                        reset()
                    }
                }
            }

            if gameState == .setting {
                GameSettingsView(rowCount: $rowCount, colCount: $colCount) {
                    withAnimation(.spring(duration: 1)) {
                        createGrid(rowCount: rowCount, colCount: colCount)
                        gameState = .waiting
                    }
                }
            }

            if isHoveringInfo {
                GameInfoView()
                    .overlayStyle()
            }
        }
        .frame(width: frameWidth, height: frameHeight)
    }
}

extension ContentView {
    var statusEmoji: String {
        if isHoveringRestart {
            "🫣"
        } else {
            switch gameState {
            case .setting, .waiting, .playing:
                "😬"
            case .won:
                "🥳"
            case .lost:
                "😢"
            }
        }
    }
    var allSquares: [Square] {
        rows.flatMap { $0 }
    }

    var revealedSquares: [Square] {
        allSquares.filter(\.isRevealed)
    }

    var flaggedSquares: [Square] {
        allSquares.filter(\.isFlagged)
    }

    var minedSquares: [Square] {
        allSquares.filter(\.hasMine)
    }

    var tappedMinesCount: Int {
        3-lifesLeft
    }
    
    var minesLeft: Int {
        max(0, minedSquares.count - flaggedSquares.count - tappedMinesCount)
    }

    func checkForWin() {
        if revealedSquares.count == allSquares.count - minedSquares.count + tappedMinesCount && flaggedSquares.count == minedSquares.count - tappedMinesCount {
            withAnimation(.spring(duration: 1)) {
                gameState = .won
            }
        }
    }

    func flag(_ square: Square) {
        if square.isRevealed { return }
        square.isFlagged.toggle()
        checkForWin()
    }

    func select(_ square: Square) {
        guard gameState == .waiting || gameState == .playing else { return }
        if square.isRevealed || square.isFlagged { return }

        if revealedSquares.count == 0 {
            placeMines(avoiding: square)
            gameState = .playing
        }
        if !square.hasMine && square.nearbyMines == 0 {
            reveal(square)
        } else {
            square.isRevealed = true

            if square.hasMine {
                lifesLeft -= 1
                secondsElapsed += 10
                if lifesLeft == 0 {
                    withAnimation(.spring(duration: 1)) {
                        gameState = .lost
                    }
                }
            }
        }

        checkForWin()
    }

    func reveal(_ square: Square) {
        if square.isRevealed || square.isFlagged { return }

        square.isRevealed = true

        if square.nearbyMines > 0 { return }

        let neighbors = getNeighborSquares(atRow: square.row, atCol: square.col)
        for neighbor in neighbors {
            reveal(neighbor)
        }
    }

    func createGrid(rowCount: Int = 10, colCount: Int = 10) {
        rows.removeAll()
        withAnimation(.spring(duration: 0.25)) {
            squareSize = 750.0 / CGFloat(max(colCount, rowCount))
            frameWidth = CGFloat(colCount) * squareSize
            frameHeight = CGFloat(rowCount) * squareSize
            for row in 0..<rowCount {
                var gridRow = [Square]()
                for col in 0..<colCount {
                    let square = Square(row: row, col: col)
                    gridRow.append(square)
                }
                rows.append(gridRow)
            }
        }
    }

    func getSquare(atRow row: Int, atCol col: Int) -> Square? {
        if row < 0 || row >= rows.count { return nil }
        if col < 0 || col >= rows[row].count { return nil }
        return rows[row][col]
    }

    func getNeighborSquares(atRow row: Int, atCol col: Int) -> [Square] {
        var neighbors = [Square?]()

        neighbors.append(getSquare(atRow: row - 1, atCol: col - 1))
        neighbors.append(getSquare(atRow: row - 1, atCol: col))
        neighbors.append(getSquare(atRow: row - 1, atCol: col + 1))

        neighbors.append(getSquare(atRow: row, atCol: col - 1))
        neighbors.append(getSquare(atRow: row, atCol: col + 1))

        neighbors.append(getSquare(atRow: row + 1, atCol: col - 1))
        neighbors.append(getSquare(atRow: row + 1, atCol: col))
        neighbors.append(getSquare(atRow: row + 1, atCol: col + 1))

        return neighbors.compactMap { $0 }
    }

    func placeMines(avoiding: Square) {
        var possibleSquares = allSquares
        let mineCount = max(10, 10 * (max(rowCount, colCount) - 10))
        let disallowed =
            getNeighborSquares(atRow: avoiding.row, atCol: avoiding.col)
            + CollectionOfOne(avoiding)
        possibleSquares.removeAll(where: disallowed.contains)

        for square in possibleSquares.shuffled().prefix(mineCount) {
            square.hasMine = true
        }

        for row in rows {
            for square in row {
                if square.hasMine { continue }
                let neighbors = getNeighborSquares(atRow: square.row, atCol: square.col)
                square.nearbyMines = neighbors.filter { $0.hasMine }.count
            }
        }
    }

    func reset() {
        secondsElapsed = 0
        gameState = .setting
        lifesLeft = 3
        createGrid(rowCount: rowCount, colCount: colCount)
    }
}

#Preview {
    ContentView()
}
