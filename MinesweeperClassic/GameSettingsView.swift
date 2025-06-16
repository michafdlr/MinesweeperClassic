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
                        .font(.title3.bold())
                }
                .frame(maxWidth: 120)
                .padding(.trailing)
                
                
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
                        .font(.title3.bold())
                }
                .frame(maxWidth: 120)
            }
            .padding([.bottom, .horizontal])
            .frame(maxWidth: .infinity)

            HStack {
                Button(action: startGame) {
                    if #available(iOS 26.0, macOS 26.0, *) {
                        Text("Play")
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .foregroundStyle(.white)
                            .background(.blue.gradient.opacity(0.6), in: Capsule())
                            .clipShape(Capsule())
                            .glassEffect()
                    } else {
                        // Fallback on earlier versions
                        Text("Play")
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .foregroundStyle(.white)
                            .background(.blue.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .font(.title)
                .buttonStyle(.plain)
                
                Button {
                    withAnimation{
                        recordsShowing.toggle()
                    }
                } label: {
                    if #available(iOS 26.0, macOS 26.0, *) {
                        Text(recordsShowing ? "Hide Records": "Show Records")
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .foregroundStyle(.white)
                            .background(.gray.gradient.opacity(0.6), in: Capsule())
                            .clipShape(Capsule())
                            .glassEffect()
                    } else {
                        // Fallback on earlier versions
                        Text(recordsShowing ? "Hide Records": "Show Records")
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .foregroundStyle(.white)
                            .background(.gray.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .font(.title)
                .buttonStyle(.plain)
                .disabled(records.isEmpty)

                Button {
                    withAnimation {
                        isShowingInfo.toggle()
                    }
                } label: {
                    if #available(iOS 26.0, macOS 26.0, *) {
                        Image(systemName: "info.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.gray.opacity(0.8))
                            .glassEffect()
                    } else {
                        // Fallback on earlier versions
                        Image(systemName: "info.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.gray.opacity(0.8))
                    }
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
