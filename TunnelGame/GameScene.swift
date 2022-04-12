//
//  GameScene.swift
//  TunnelGame
//
//  Created by Adrian Siwy on 9/25/15.
//  Copyright (c) 2015 Adrian Siwy. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // PhaseController is the heart of the game's progression and controls the parallax
    let phaseController = PhaseController()
    // Used for determining the time elapsed in the update method
    var lastUpdateTimeInterval: CFTimeInterval = 0
    // Keeps the everything on one node that can be scaled up and simply added to the scene
    let scaledNode = SKNode()
    // The player is the way the user interacts with the game
    let player = Player()
    
    //let layerDetailGenerator = LayerDetailGenerator()
    
//    lazy var phaseController: PhaseController = {
//        [unowned self] in
//        return PhaseController(sceneSize: self.size)
//    }()
    
//    override init() {
//        super.init()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    
    override func didMove(to view: SKView) {
        
        // Set the scene size to the view size (make game window same as view window)
        size = view.frame.size
        
        // Add the parallax node to the GameScene
        addChild(phaseController.parallax)
        
        // Add the player to the staticLayer of Parallax
        phaseController.parallax.staticLayer.addChild(player.node)
        player.node.setScale(1.5)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.location(in: self)
            
            player.setNewTarget(location)
            print("tap X: \(location.x) Y: \(location.y)")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch is moved */
        
        for touch in touches {
            let location = touch.location(in: self)
            
            player.setNewTarget(location)
        }
    }
    
    // Keeps the scene syncronized
    func updateWithTimeSinceLastUpdate(_ elapsedTime: CFTimeInterval) {
        /* Called by the update method with the delta of the current and previous time intervals*/
        
        phaseController.iterateFrame(elapsedTime, flyingSpeed: player.flyingSpeed)
        if player.targetExists {
            player.move(elapsedTime)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        // Find the elapsedTime and set the lastUpdateTimeInterval to the current time interval
        let elapsedTime: CFTimeInterval = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        
        // Call the new update method that takes the elapsedTime as a parameter. If lastUpdateTimeInterval is 0, then the update just started and there is no elapsedTime
        updateWithTimeSinceLastUpdate(elapsedTime > 1.0 ? 0 : elapsedTime)
    }
}
