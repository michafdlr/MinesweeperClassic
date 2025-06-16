//
//  Particle.swift
//  MinesweeperClassic
//
//  Created by Michael Fiedler on 15.06.25.
//

import SwiftUI

extension Double {
    func spread() -> Self {
        Self.random(in: -self/2...self/2)
    }
}

extension BinaryFloatingPoint {
    func lerp(to value: Self, amount: Self) -> Self {
        self + (value - self) * amount
    }
}

enum ParticleSystemShape {
    case point
    case box(width: Double, height: Double)
}

struct Particle {
    var position: SIMD2<Double>
    var speed: SIMD2<Double>
    let launchAngle: Double
    var birthTime: Double
    var lifespan: Double
    var startSize: Double
    var currentSize = 0.0
    var tag: String
    var angle = SIMD3<Double>()
    var spinSpeed: SIMD3<Double>
//    var colors = stride(from: 0, through: 1, by: 0.1).map { i in
//        Color.init(hue: i, saturation: 1, brightness: 1)
//    }
    var currentColor = Color.init(hue: Double.random(in: 0...1), saturation: 1, brightness: 1)
    var colorRotation = Angle(degrees: 0)
}

class ParticleSystem {
    var particles = [Particle]()
    var position = SIMD2(x: 0.5, y: 0.5)
    var lastUpdate = Date.now.timeIntervalSince1970
    
    var lifespan = 1.0
    var size = 1.0
    var speed = 1.0
    
    var lifeVary = 0.0
    var speedVary = 0.0
    var sizeVary = 0.0
    
    var sizeAtDeath = 1.0
    
    var acceleration = SIMD2<Double>()
    
    var tags = [String]()
    
    var color = Color.white
    
    var spinSpeed = SIMD3<Double>()
    var spinSpeedVary = SIMD3<Double>()
    
    var shape = ParticleSystemShape.point
    
    var angle: Angle = Angle.zero
    var angleVary: Angle = Angle.zero
    
    
    func createParticle() {
        let launchAngle = angle.radians + angleVary.radians.spread() - .pi/2
        let launchSpeed = speed + speedVary.spread()
        let lifespan = lifespan + lifeVary.spread()
        let size = size + sizeVary.spread()
        
        let xSpeed = cos(launchAngle) * launchSpeed
        let ySpeed = sin(launchAngle) * launchSpeed
        
        let spin = SIMD3(
            x: spinSpeed.x + spinSpeedVary.x.spread(),
            y: spinSpeed.y + spinSpeedVary.y.spread(),
            z: spinSpeed.z + spinSpeedVary.z.spread()
            )
        
        let newPosition: SIMD2<Double>
        
        switch shape {
        case .point:
            newPosition = position
        case .box(let width, let height):
            newPosition = [
                position.x + width.spread(),
                position.y + height.spread()
            ]
        }
        
        let newParticle = Particle(
            position: newPosition,
            speed: [xSpeed, ySpeed],
            launchAngle: launchAngle,
            birthTime: lastUpdate,
            lifespan: lifespan,
            startSize: size,
            tag: tags.randomElement() ?? "",
            spinSpeed: spin
        )
        particles.append(newParticle)
    }
    
    func update(date: Date) {
        let current = date.timeIntervalSince1970
        let delta = current - lastUpdate
        lastUpdate = current
        
        createParticle()
        
        particles = particles.compactMap{ particle in
            var copy = particle
            copy.position += copy.speed * delta
            copy.speed += acceleration * delta
            copy.angle += copy.spinSpeed * delta
            
            let age = current - copy.birthTime
            let progress = age / copy.lifespan
            let targetSize = copy.startSize * sizeAtDeath
            let gap = targetSize - copy.startSize
            
            copy.colorRotation = Angle(degrees: progress * 360)
            
            copy.currentColor = Color.init(hue: copy.colorRotation.radians / (2 * .pi), saturation: 1, brightness: 1) //copy.colors.randomElement() ?? .white
            
            copy.currentSize = copy.startSize + gap*progress
            
            if age >= copy.lifespan {
                return nil
            } else {
                return copy
            }
        }
    }
}
