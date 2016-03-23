//
//  PlayerNode.swift
//  TunnelGame
//
//  Created by Adrian Siwy on 3/22/16.
//  Copyright © 2016 Adrian Siwy. All rights reserved.
//

import SpriteKit

class Player {
    
    var firingSpeed = 0.0 // <- shots per second
    var flyingSpeed = 0.0 // <- cycles per second
    var node = SKSpriteNode(imageNamed: "player")
    var location: CGPoint {
        get {
            return node.position
        }
        
        set(newLocation) {
            if newLocation.y > 100 {
                node.position.x = newLocation.x
                node.position.y = 100
                flyingSpeed = 0.5 // <- constant needs to be determined
            } else {
                node.position = newLocation
                flyingSpeed = Double(newLocation.y) / 200 // <- speed of just the player, the baseSpeed is added to this in PhaseController
            }
        }
    }
}
