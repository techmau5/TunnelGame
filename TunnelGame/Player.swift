//
//  PlayerNode.swift
//  TunnelGame
//
//  Created by Adrian Siwy on 3/22/16.
//  Copyright © 2016 Adrian Siwy. All rights reserved.
//

import SpriteKit

/* NOTES:
 Consider changing angle calculated to be between 0 and 2PI instead of -PI and PI
 
*/

class Player {
    
    // Player Basic Properties
    var node = SKSpriteNode(imageNamed: "player") // <- physical node of the player
    var firingSpeed = 0.0 // <- shots per second
    var flyingSpeed = 0.0 // <- cycles per second
    
    // Player Physics Properties
    var velocity: Double = 0 //the current speed of the player; (pixels / second)
    let MAX_VELOCITY = 170.0
    var acceleration: Double = 50 //constant, but keep var so it can be changed; in (pixels / second squared)
    var angle: Double = 0 //the angle that the player is travelling at
    var angleAccelDir: Int = 0
    var angularVelocity: Double = 0 //the speed of rotation towards the target angle; (radians / second)
    var angularAcceleration: Double = M_PI * 2 //constant, but keep so it can be changed; in (radians / second squared)
    var currentLocation: CGPoint {
        get {
            return node.position
        }
        set(point) {
            node.position = point
        }
    }
    
    // Player Target Properties
    var targetExists = false
    var targetAngle: Double = 0
    var atTargetAngle = false
    var targetLocation: CGPoint = CGPoint(x: 0, y: 0)
    
    func move(_ elapsedTime: CFTimeInterval) {
        
        // Accelerate the velocity if it is lower than the MAX_VELOCITY
        if velocity < MAX_VELOCITY {
            velocity = velocity + acceleration * elapsedTime
            if velocity > MAX_VELOCITY {
                velocity = MAX_VELOCITY
            }
        }
        
        // Calculate the displacement for the frame
        let displacement = velocity * elapsedTime
        
        // Find the targetAngle using the targetLocation and currentLocation
        targetAngle = Double(atan2f(Float(targetLocation.y - currentLocation.y), Float(targetLocation.x - currentLocation.x)))
        
        // If the player is not at the targetAngle, then accelerate him in that direction
        if atTargetAngle == false {
            angle = getNewAngle(elapsedTime)
        }
        
        print(angle)
        
        // Calculate the change in position for x and y
        let dx = CGFloat(displacement * cos(angle))
        let dy = CGFloat(displacement * sin(angle))
        
        // Move the player
        currentLocation = CGPoint(x: currentLocation.x + dx, y: currentLocation.y + dy)
        
        // Check to see if the player is at the target position; stop the player if so
        if (abs(targetLocation.x - currentLocation.x) < 2 && abs(targetLocation.y - currentLocation.y) < 2) {
            currentLocation = targetLocation
            targetExists = false
            angularVelocity = 0
            velocity = 0
        }
    }
    
    func getNewAngle(_ elapsedTime: CFTimeInterval) -> Double {
        
        // Determine if the angle is already the targetAngle; if not, apply the angularVelocity
        var newAngle: Double
        
        angularVelocity = angularVelocity + angularAcceleration * elapsedTime * Double(angleAccelDir)
        newAngle = angle + angularVelocity * elapsedTime
            
        // If the newAngle goes past the targetAngle, set it to the targetAngle instead; also set the angularVelocity to 0
        if (abs(newAngle - angle) >= abs(targetAngle - angle)) {
            newAngle = targetAngle
            atTargetAngle = true
            angularVelocity = 0
        }
        
        //If the angle goes over PI or -PI then change respectively
        if abs(newAngle) > M_PI {
            if newAngle > 0 {
                newAngle -= 2 * M_PI
            } else {
                newAngle += 2 * M_PI
            }
        }
        
        return newAngle
    }
    
    func setNewTarget(_ location: CGPoint) {
        
        // Set the position of the target to the touch location
        targetLocation = location
        
        // Find the targetAngle using the targetLocation and currentLocation
        targetAngle = Double(atan2f(Float(targetLocation.y - currentLocation.y), Float(targetLocation.x - currentLocation.x)))
        
        // If the target does not exist, the player is not moving and should start at the targetAngle
        // Modify the velocity and angularVelocity to boost speed or change direction
        if targetExists {
            //ends up with 1 or -1
            let angleToTarget = Int(atan2(sin(targetAngle - angle), cos(targetAngle - angle)))
            if angleToTarget > 0 {
                angleAccelDir = 1
                angularVelocity += 0.9
            } else if angleToTarget < 0 {
                angleAccelDir = -1
                angularVelocity -= 0.9
            }
            print(angleAccelDir)
            
            atTargetAngle = false
        }
        else {
            angle = targetAngle
            velocity = 80
            targetExists = true
            atTargetAngle = true
        }
    }
}

//class PlayerOld {
//    
//    // Player Basic Properties
//    var node = SKSpriteNode(imageNamed: "player") // <- physical node of the player
//    var firingSpeed = 0.0 // <- shots per second
//    var flyingSpeed = 0.0 // <- cycles per second
//    // The location property calculates the node location, flyingSpeed, and firingSpeed
//    var location: CGPoint {
//        get {
//            
//            return node.position
//        }
//        
//        set(newLocation) {
//            
//            setNewAppliedVector(newLocation)
//            
//            // The maximum height the player can move
//            let maxHeight = CGFloat(UIScreen.mainScreen().applicationFrame.height / 4)
//            
//            // Set the player x position
//            node.position.x = newLocation.x
//            
//            // Set the player to the y position or maxHeight
//            if newLocation.y >= maxHeight {
//                node.position.y = maxHeight + 10
//            } else {
//                node.position.y = newLocation.y + 10
//            }
//            
//            // Change the flyingSpeed based on the position of the player
//            if newLocation.y >= (maxHeight * (3 / 4)) {
//                flyingSpeed = 0.5
//            } else if newLocation.y < (maxHeight * (3 / 4)) && newLocation.y >= (maxHeight * (1 / 4)) {
//                flyingSpeed = Double((newLocation.y - (maxHeight * (1 / 4))) / maxHeight * (1 / 2)) * 2
//            } else {
//                flyingSpeed = 0 // <- constant needs to be determined
//            }
//        }
//    }
//    
//    // Player Physics properties
//    var xVelocity: CGFloat = 0.0
//    var yVelocity: CGFloat = 0.0
//    var acceleration: CGFloat = 0.0
//    var appliedVector: CGVector = CGVectorMake(0, 0) // <- force vector applied to the player
//    
//    func setNewAppliedVector(location: CGPoint) {
//        appliedVector = CGVectorMake(acceleration * cos(tan((location.x - node.position.x) / (location.y - node.position.y))) , acceleration * sin(tan((location.x - node.position.x) / (location.y - node.position.y))))
//        print(appliedVector.dx, appliedVector.dy)
//    }
//}
