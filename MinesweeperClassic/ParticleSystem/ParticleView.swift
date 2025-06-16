//
//  ParticleView.swift
//  MinesweeperClassic
//
//  Created by Michael Fiedler on 15.06.25.
//

import SwiftUI

struct ParticleView<Symbols>: View where Symbols: View {
    @State var system: ParticleSystem
    var targetFrameRate: Int
    @ViewBuilder var symbols: Symbols
    
    
    init(_ system: ParticleSystem, targetFrameRate: Int = 60, @ViewBuilder symbols: () -> Symbols) {
        _system = State(initialValue: system)
        self.symbols = symbols()
        self.targetFrameRate = targetFrameRate
    }
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/Double(targetFrameRate))) { timeline in
            Canvas { context, size in
                system.update(date: timeline.date)
                draw(system, into: context, at: size)
            } symbols: {
               symbols
            }
        }
    }
}

extension ParticleView {
    func draw(_ system: ParticleSystem, into context: GraphicsContext, at size: CGSize) {
        for p in system.particles {
            let x = p.position.x * size.width
            let y = p.position.y * size.height
            
            var transform = CATransform3DIdentity
            
            transform = CATransform3DRotate(transform, p.angle.x, 1, 0, 0)
            transform = CATransform3DRotate(transform, p.angle.y, 0, 1, 0)
            transform = CATransform3DRotate(transform, p.angle.z, 0, 0, 1)
            
            var ctx = context
            
            ctx.translateBy(x: x, y: y)
            ctx.scaleBy(x: p.currentSize, y: p.currentSize)
            ctx.addFilter(
                .projectionTransform(ProjectionTransform(transform))
            )
            ctx.addFilter(
                .colorMultiply(system.color)
            )
            ctx.addFilter(.colorMultiply(p.currentColor))
            
            if let view = ctx.resolveSymbol(id: p.tag) {
                ctx.draw(view, at: .zero)
            }
        }
    }
}

//#Preview {
//    ParticleView()
//}
