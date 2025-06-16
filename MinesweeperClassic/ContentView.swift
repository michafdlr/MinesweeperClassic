//
//  ContentView.swift
//  MinesweeperClassic
//
//  Created by Michael Fiedler on 25.05.25.
//

import SwiftUI

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
    @State private var squareSize = 0.0
    @State private var lifesLeft = 3
    
    @State private var infoHeight = 75.0

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .font(.custom("Courier", size: textSize))
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
                        
                        HStack {
                            Text(minesLeft, format: .number.precision(.integerLength(3)))
                                .fixedSize()
                                .padding(.horizontal, 6)
                                .foregroundStyle(.red.gradient)
                                .font(.custom("Courier", size: textSize))

                            Button{
                                reset(screenWidth: proxy.size.width, screenHeight: proxy.size.height)
                            } label: {
                                HStack {
                                    Text(statusEmoji)
                                    Text("Restart")
                                        .font(.custom("Courier", size: textSize))
                                }
                                .padding(5)
//                                .frame(idealWidth: 150, maxWidth: .infinity)
                                .background(.gray.gradient.opacity(0.5))
                                .clipShape(.rect(cornerRadius: 6))
                            }
                            .onHover { isHoveringRestart = $0 }
                            .buttonStyle(.plain)

                            Text(secondsElapsed, format: .number.precision(.integerLength(3)))
                                .fixedSize()
                                .padding(.horizontal, 6)
                                .foregroundStyle(.red.gradient)
                                .font(.custom("Courier", size: textSize))
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
                                    .font(.custom("Courier", size: textSize))
                                    .animation(
                                        .linear(duration: 0.5).repeatCount(
                                            7,
                                            autoreverses: true
                                        ),
                                        value: lifesLeft
                                    )
                            }
                        }
                    }
                    .frame(width: proxy.size.width, height: infoHeight)
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
                    .clipShape(.rect(cornerRadius: 8))
                    .padding([.horizontal, .bottom], 5)
                    .transition(.scale(scale: 2).combined(with: .opacity))
                    .onAppear {
                        createGrid(screenWidth: proxy.size.width, screenHeight: proxy.size.height)
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
                            reset(screenWidth: proxy.size.width, screenHeight: proxy.size.height)
                        }
                    }
                }

                if gameState == .setting {
                    GameSettingsView(rowCount: $rowCount, colCount: $colCount) {
                        withAnimation(.spring(duration: 1)) {
                            createGrid(rowCount: rowCount, colCount: colCount, screenWidth: proxy.size.width, screenHeight: proxy.size.height)
                            gameState = .waiting
                        }
                    }
                }

                if isHoveringInfo {
                    GameInfoView()
                        .overlayStyle()
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
            .onChange(of: proxy.size) { _, newValue in
                resizeSquare(screenWidth: newValue.width, screenHeight: newValue.height)
            }
            .onChange(of: gameState) { _, newValue in
                if newValue == .won || newValue == .lost {
                    withAnimation(.spring(duration: 1)) {
                        revealAll()
                    }
                }
            }
        }
    }
}

extension ContentView {
    var statusEmoji: String {
        if isHoveringRestart {
            "🫣"
        } else {
            switch gameState {
            case .setting, .waiting, .playing:
                "😊"
            case .won:
                "🥳"
            case .lost:
                "😢"
            }
        }
    }
    
    var textSize: CGFloat {
        infoHeight/4
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
    
    func revealAll() {
        allSquares.forEach { $0.isRevealed = true }
    }
    
    func resizeInfoHeight(screenWidth: Double, screenHeight: Double) {
        infoHeight = 0.1*screenHeight
    }
    
    func resizeSquare(screenWidth: Double, screenHeight: Double) {
        squareSize = max(min(screenWidth - infoHeight, screenHeight-1.5*infoHeight), 1) / CGFloat(max(colCount, rowCount))
    }

    func createGrid(rowCount: Int = 10, colCount: Int = 10, screenWidth: Double, screenHeight: Double) {
        rows.removeAll()
        withAnimation(.spring(duration: 0.25)) {
            squareSize = max(min(screenWidth - infoHeight, screenHeight-1.5*infoHeight), 1) / CGFloat(max(colCount, rowCount))
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

    func reset(screenWidth: Double, screenHeight: Double) {
        secondsElapsed = 0
        gameState = .setting
        lifesLeft = 3
        createGrid(rowCount: rowCount, colCount: colCount, screenWidth: screenWidth, screenHeight: screenHeight)
    }
}

#Preview {
    ContentView()
}
