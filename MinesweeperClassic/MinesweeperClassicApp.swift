//
//  MinesweeperClassicApp.swift
//  MinesweeperClassic
//
//  Created by Michael Fiedler on 25.05.25.
//

import SwiftUI

@main
struct MinesweeperClassicApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, idealWidth: 742, minHeight: 400, idealHeight: 821, alignment: .center)
        }
        .windowResizability(.contentSize)
    }
}
