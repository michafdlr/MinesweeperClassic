//
//  ParticleSimulationView.swift
//  MinesweeperClassic
//
//  Created by Michael Fiedler on 15.06.25.
//

import SwiftUI

struct ParticleSimulationView: View {
    var tag: String
    var size: Double {
        if tag == "star" {
            return 3.0
        }
        return 1.0
    }
    
    var body: some View {
        ParticleView(createSystem(size: size)) {
            if tag == "star" {
                Image(systemName: "star.fill")
                    .foregroundStyle(.white)
                    .blendMode(.plusLighter)
                    .tag("star")
            } else {
                Image("mineSmall")
                    .foregroundStyle(.white)
                    .blendMode(.plusLighter)
                    .tag("mine")
            }
        }
    }
    
    func createSystem(size: Double = 1.0) -> ParticleSystem {
        let system = ParticleSystem()
        system.speed = 0.2
        system.speedVary = 0.1
        system.lifespan = 3.0
        system.lifeVary = 1.0
        system.size = size
        system.sizeVary = 1
        system.sizeAtDeath = 0
        system.acceleration = [0, 0.2]
        system.tags = ["mine", "star"]
        system.color = .white
        system.spinSpeed = [1, 2, 2]
        system.spinSpeedVary = [0.5, 0.5, 0.5]
        system.shape = .box(width: 1, height: 0)
        system.position = [0.5, 0]
        system.angle = Angle(degrees: 180)
        system.angleVary = Angle(degrees: 10)
        
        return system
    }
}

#Preview {
    ParticleSimulationView(tag: "star")
}
