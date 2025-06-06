//
//  GameInfoView.swift
//  MinesweeperClassic
//
//  Created by Michael Fiedler on 30.05.25.
//

import SwiftUI

struct GameInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How to play Minesweeper")
                .font(.largeTitle.bold())
            
            Text("Your target is to find all mines. When no field has been tapped, simply tap an arbitrary field.\nThe numbers appearing in the fields show by how many mines the certain field is surrounded.\nTo mark possible mines you can put a flag on that field by long-tapping the certain field.\nYour goal is to clear all fields that do not contain a mine.")
                .multilineTextAlignment(.leading)
            
            Text("Good Luck!!!")
                .font(.title.bold())
                .textCase(.uppercase)
        }
//        .overlayStyle()
    }
}

#Preview {
    GameInfoView()
}
