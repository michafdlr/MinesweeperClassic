//
//  NonPlayingViewModifiers.swift
//  MinesweeperClassic
//
//  Created by Michael Fiedler on 30.05.25.
//

import SwiftUI

struct OverlayView: ViewModifier {
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(.dark)
            .transition(.scale(scale: 2).combined(with: .opacity))
            .padding(.vertical)
            .padding(.bottom, 5)
            .frame(maxWidth: .infinity)
            .background(.black.opacity(0.75).gradient)
            .clipShape(.rect(cornerRadius: 10))
    }
}

extension View {
    func overlayStyle() -> some View {
        modifier(OverlayView())
    }
}

#Preview {
    Text("Hello, world!")
        .overlayStyle()
        .padding(50)
}
