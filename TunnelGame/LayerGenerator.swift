//
//  LayerGenerator.swift
//  TunnelGame
//
//  Created by Adrian Siwy on 2/10/16.
//  Copyright © 2016 Adrian Siwy. All rights reserved.
//

import SpriteKit

//this class has class methods and is not meant to be instantiated
class LayerGenerator {
    
    //the textureAtlas holds the sprites needed for the layer details
    static let textureAtlas = SKTextureAtlas(named: "test")
    static var currentPhase = PhaseType.StartPhase
    
    //calls the appopriate generate method depending on the parallax layer that is requesting it
    class func generateNode(layerType: LayerType) -> SKNode {
        
        let newNode: SKNode
        
        switch layerType {
        case .BackgroundLayer:
            newNode = generateBackgroundLayerNode()
        case .MainLayer:
            newNode = generateMainLayerNode()
        case .ForegroundLayer:
            newNode = generateForegroundLayerNode()
        }
        
        return newNode
    }
    
    //generates a background layer node
    class func generateBackgroundLayerNode() -> SKNode {
        
        let newNode = SKNode()
        
        // TEST CODE
        let newSprite = SKSpriteNode(imageNamed: "Shape")
        newSprite.position = CGPointMake(100, 100)
        newNode.addChild(newSprite)
        
        return newNode
    }
    
    //generates a main layer node
    class func generateMainLayerNode() -> SKNode {
        
        let newNode = SKNode()
        
        // TEST CODE
        let newSprite = SKSpriteNode(imageNamed: "Shape")
        newSprite.position = CGPointMake(100, 100)
        newNode.addChild(newSprite)
        
        return newNode
    }
    
    //generates a foreground layer node
    class func generateForegroundLayerNode() -> SKNode {
        
        let newNode = SKNode()
        
        // TEST CODE
        let newSprite = SKSpriteNode(imageNamed: "Shape")
        newSprite.position = CGPointMake(100, 100)
        newNode.addChild(newSprite)
        
        return newNode
    }
}
