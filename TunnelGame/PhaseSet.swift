//
//  PhaseSet.swift
//  TunnelGame
//
//  Created by Adrian Siwy on 10/9/15.
//  Copyright © 2015 Adrian Siwy. All rights reserved.
//

class PhaseSet {

    // Phase Set Properties
    let exitCount: Int // <- number of exits
    let baseSpeed: Double // <- slowest speed the player can go: cycles per second
    let actionDuration: Double
    let midDuration = 5.0 // <- to be changed
    let startDurationPerExit = 3.0 // <- not sure about this
    let startCycles: Int
    let midCycles: Int
    let actionCycles: Int
    
    // Set and calculate values for properties
    init(exitCount: Int, baseSpeed: Double, actionDuration: Double) {
        
        self.exitCount = exitCount
        self.baseSpeed = baseSpeed
        self.actionDuration = actionDuration
        
        // Number of cycles for each phase is an Int, the Double value is rounded after X.5
        startCycles = Int(baseSpeed * startDurationPerExit * Double(exitCount) + 0.5) * 2
        midCycles = Int(baseSpeed * midDuration + 0.5) * 2
        actionCycles = Int(baseSpeed * actionDuration + 0.5) * 2
        
        print(startCycles)
        print(midCycles)
        print(actionCycles)
    }
}