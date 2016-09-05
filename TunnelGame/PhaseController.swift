//
//  PhaseController.swift
//  TunnelGame
//
//  Created by Adrian Siwy on 10/9/15.
//  Copyright © 2015 Adrian Siwy. All rights reserved.
//

import SpriteKit

class PhaseController {

    // Parallax moves the game layers based on cycles
    let parallax: Parallax
    // The PhaseSet defines the current phase constraints
    var phaseSet: PhaseSet
    // The current phase of the game, updates the currentPhase var in LayerGenerator as well
    var currentPhase: PhaseType = .StartPhase {
        willSet {
            //LayerGenerator.currentPhase = newValue
        }
    }
    
    // The completed exit count keeps track of the phaseSet progress
    var completedExitCount = 0
    
    init() {
        
        // Create the parallax controller with the GameScene CGSize
        parallax = Parallax()
        
        // Load a new phase set manually here (temp one is generated for testing)
        // This will act as the default starting phase set
        // This may later be replaced by a saved phaseSet to load from storage
        phaseSet = PhaseSet(exitCount: 3, baseSpeed: 0.5, actionDuration: 10)
        
        //parallax.phaseSpeed = phaseSet.phaseSpeed
        parallax.cycleLimit = phaseSet.startCycles
    }
    
    // Request next PhaseSet from PhaseSetGenerator
    func loadNextPhaseSet() {
        
        // TEST CODE
        print("The PhaseSet has completed")
        
        // Set the phaseSet with the new PhaseSet parameter
        phaseSet = PhaseSetGenerator.generateNextPhaseSet(phaseSet)
        
        // Cover screen with foreground
        
        // Reset the ParallaxController -> ParallaxLayer -> cycleNodes
        parallax.resetParallaxLayers()
        
        // Reset the player location
        // Reset other vars in player class
        
    }
    
    // This method is called by the GameScene and performs actions specific to the current phase
    func iterateFrame(elapsedTime: CFTimeInterval, flyingSpeed: Double) {
        
        // The method iterates the parallax and determines if the Phase should be switched
        // Player speed is the flyingSpeed of the player added to the baseSpeed
        if parallax.continueCycle(elapsedTime, playerSpeed: flyingSpeed + phaseSet.baseSpeed) {
            switchToNextPhase()
        }
    }
    
    func switchToNextPhase() {
        
        switch currentPhase {
        case .StartPhase:
            currentPhase = .ActionPhase
            parallax.cycleLimit = phaseSet.actionCycles
            parallax.resetParallaxLayers()
            print("Enter Action Phase")
        case .ActionPhase:
            currentPhase = .ChoicePhase
            
            // TEST CODE - to be replaced with the exit choosing process
            parallax.cycleLimit = 2
            parallax.resetParallaxLayers()
            //the scrolling should ease to a stop and the player should ease to the top of the screen (momentum is transfered)
            completedExitCount += 1
            print("Choice Phase Begins")
        case .ChoicePhase:
            if completedExitCount < phaseSet.exitCount {
                currentPhase = .ActionPhase
                parallax.cycleLimit = phaseSet.actionCycles
                parallax.resetParallaxLayers()
                print("Next Action Phase")
            } else {
                loadNextPhaseSet()
            }
        }
    }
}

// Phase Enumeration
enum PhaseType {
    
    case StartPhase
    case ActionPhase
    case ChoicePhase
}
