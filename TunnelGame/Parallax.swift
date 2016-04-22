//
//  Parallax.swift
//  TunnelGame
//
//  Created by Adrian Siwy on 10/9/15.
//  Copyright © 2015 Adrian Siwy. All rights reserved.
//

import SpriteKit

class Parallax: SKNode {
    
    static let screenHeight = UIScreen.mainScreen().applicationFrame.height
    var cycleLimit = 10 // <- must be even to ensure that the nodes will all be alligned
    var currentCycleCount = 0
    let backgroundLayer = ParallaxLayer(type: .BackgroundLayer)
    let mainLayer = ParallaxLayer(type: .MainLayer)
    let foregroundLayer = ParallaxLayer(type: .ForegroundLayer)
    let staticLayer = SKNode() // <- moves upward when the moving layers deccelerate
    
    // Set the layer Z positions
    override init() {
        
        super.init()
        
        //set the appropriate z positions for each layer
        backgroundLayer.zPosition = -1
        mainLayer.zPosition = 0
        staticLayer.zPosition = 1
        foregroundLayer.zPosition = 2
        
        //add the children to the parallax
        addChild(backgroundLayer)
        addChild(mainLayer)
        addChild(staticLayer)
        addChild(foregroundLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Reset the positions and contents of the parallax layers
    func resetParallaxLayers() {
        
        backgroundLayer.resetCycleLayers()
        mainLayer.resetCycleLayers()
        foregroundLayer.resetCycleLayers()
    }
    
    // Add methods for moving each layer
    
    func continueCycle(elapsedTime: CFTimeInterval, playerSpeed: Double) -> Bool {
        
        // The travelDistance is calculated using the timeElapsed the height of one cycle (screen height) and the currentPhaseSpeed (number of cycles per second)
        let travelDistance: CGFloat = CGFloat(Double(Parallax.screenHeight) * elapsedTime) * CGFloat(playerSpeed)
        
        // Move the layers by the travelDistance; the backgroundLayer moves 1/2x normal and the foregroundLayer moves 2x normal
        backgroundLayer.moveLayers(travelDistance/2)
        mainLayer.moveLayers(travelDistance)
        foregroundLayer.moveLayers(travelDistance*2)
        
        // If the mainLayer has performed the number of max cycles, return true
        if mainLayer.cycleCount >= cycleLimit {
            return true
        } else {
            return false
        }
    }
}

//CONSIDER - does each layer need a cycleCount? Shouldn't there only be one in the parallax object?
class ParallaxLayer: SKNode {
    
    let cycleNode1 = SKNode()
    let cycleNode2 = SKNode()
    var cycleCount = 0
    let layerType: LayerType
    
    // Add methods for reset and movement
    init(type: LayerType) {
        
        layerType = type
        
        super.init()
        
        // Set the second cycle node position above the other node
        cycleNode2.position = CGPointMake(0, Parallax.screenHeight)
        
        // Add the cycle nodes to the parallaxLayer
        addChild(cycleNode1)
        addChild(cycleNode2)
        
        cycleNode1.addChild(LayerGenerator.generateNode(layerType))
        cycleNode2.addChild(LayerGenerator.generateNode(layerType))
        
        //STILL NEEDED! -> get first layer set from LayerGenerator
    }
    
    func resetCycleLayers() {
        
        // Remove all of the cycle layer children and set original positions
        cycleNode1.removeAllChildren()
        cycleNode1.position = CGPointMake(0, 0)
        
        cycleNode2.removeAllChildren()
        cycleNode2.position = CGPointMake(0, Parallax.screenHeight)
        
        cycleNode1.addChild(LayerGenerator.generateNode(layerType))
        cycleNode2.addChild(LayerGenerator.generateNode(layerType))
        
        cycleCount = 0
    }
    
    // Move the layers based on the distance given
    func moveLayers(distance: CGFloat) {
        
        cycleNode1.position.y -= distance
        cycleNode2.position.y -= distance
        
        //if one of the cycle nodes goes off screen then shift it above the other node
        //the cycleNode are given a new node by the LayerGenerator
        if cycleNode1.position.y < -Parallax.screenHeight {
            cycleNode1.position.y += 2 * Parallax.screenHeight
            cycleCount += 1
            cycleNode1.removeAllChildren()
            cycleNode1.addChild(LayerGenerator.generateNode(layerType))
            
        } else if cycleNode2.position.y < -Parallax.screenHeight {
            cycleNode2.position.y += 2 * Parallax.screenHeight
            cycleCount += 1
            cycleNode2.removeAllChildren()
            cycleNode2.addChild(LayerGenerator.generateNode(layerType))
        }
    }
    
    //required code, won't be used
    required init?(coder aDecoder: NSCoder) {
        layerType = .MainLayer
        
        super.init(coder: aDecoder)
    }
}

enum LayerType {
    
    case BackgroundLayer
    case MainLayer
    case ForegroundLayer
}