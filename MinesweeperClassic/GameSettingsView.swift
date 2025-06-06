//
//  GameSettingsView.swift
//  MinesweeperClassic
//
//  Created by Michael Fiedler on 29.05.25.
//

import SwiftUI

struct GameSettingsView: View {
    @Binding var rowCount: Int
    @Binding var colCount: Int
    @State private var isShowingInfo = false

    var startGame: () -> Void

    var body: some View {
        VStack {
            Text("Minesweeper Classic")
                .textCase(.uppercase)
                .font(.system(size: 40).weight(.black))
                .foregroundStyle(.white)
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)

            HStack {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Text("Rows")
                        .font(.title3)
                }
                Picker(selection: $rowCount) {
                    if UIDevice.current.userInterfaceIdiom == .mac {
                        ForEach(10...30, id: \.self) { i in
                            Text(String(i))
                                .tag(i)
                        }
                    } else {
                        ForEach(10...20, id: \.self) { i in
                            Text(String(i))
                                .tag(i)
                        }
                    }
                } label: {
                    Text("Rows")
                        .font(.title3)
                }
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Text("Columns")
                        .font(.title3)
                }
                Picker(selection: $colCount) {
                    if UIDevice.current.userInterfaceIdiom == .mac {
                        ForEach(10...30, id: \.self) { i in
                            Text(String(i))
                                .tag(i)
                        }
                    } else {
                        ForEach(10...20, id: \.self) { i in
                            Text(String(i))
                                .tag(i)
                        }
                    }
                } label: {
                    Text("Columns")
                        .font(.title3)
                }
            }
            .padding(.bottom)
            .frame(width: 300)

            HStack {
                Button(action: startGame) {
                    Text("Start Game")
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .foregroundStyle(.white)
                        .background(.blue.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .font(.title)
                .buttonStyle(.plain)

                Button {
                    withAnimation {
                        isShowingInfo.toggle()
                    }
                } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.gray.opacity(0.8))
                }
                .buttonStyle(.plain)
            }

            if isShowingInfo {
                GameInfoView()
            }
        }
        .overlayStyle()
    }
}

#Preview {
    GameSettingsView(rowCount: .constant(10), colCount: .constant(10), startGame: {})
}
