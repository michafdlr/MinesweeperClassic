//
//  Square.swift
//  MinesweeperClassic
//
//  Created by Michael Fiedler on 25.05.25.
//

import Foundation

@Observable
class Square: Identifiable, Equatable {
    var id = UUID()
    var row: Int
    var col: Int
    
    var hasMine = false
    var isFlagged = false
    var nearbyMines = 0
    var isRevealed = false
    
    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
    
    static func ==(lhs: Square, rhs: Square) -> Bool{
        lhs.id == rhs.id
    }
}
