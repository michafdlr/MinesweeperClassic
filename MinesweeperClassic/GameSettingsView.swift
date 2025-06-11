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
    @State private var recordsShowing = false
    
    var records = getAllRecords()

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
                #if os(iOS)
                    Text("Rows")
                        .font(.title3)
                #endif
                Picker(selection: $rowCount) {
                    #if os(macOS)
                        ForEach(10...30, id: \.self) { i in
                            Text(String(i))
                                .tag(i)
                        }
                    #else
                        ForEach(10...20, id: \.self) { i in
                            Text(String(i))
                                .tag(i)
                        }
                    #endif
                } label: {
                    Text("Rows")
                        .font(.title3)
                }
                
                #if os(iOS)
                    Text("Columns")
                        .font(.title3)
                #endif
                Picker(selection: $colCount) {
                    #if os(macOS)
                        ForEach(10...30, id: \.self) { i in
                            Text(String(i))
                                .tag(i)
                        }
                    #else
                        ForEach(10...20, id: \.self) { i in
                            Text(String(i))
                                .tag(i)
                        }
                    #endif
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
                    withAnimation{
                        recordsShowing.toggle()
                    }
                } label: {
                    Text(recordsShowing ? "Hide Records": "Show Records")
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .foregroundStyle(.white)
                        .background(.gray.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .font(.title)
                .buttonStyle(.plain)
                .disabled(records.isEmpty)

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
            
            if recordsShowing && !records.isEmpty {
                RecordsView()
                    .padding()
            }
        }
        .overlayStyle()
    }
}

#Preview {
    GameSettingsView(rowCount: .constant(10), colCount: .constant(10), startGame: {})
}
