//
//  GameScene.swift
//  TunnelGame
//
//  Created by Adrian Siwy on 9/25/15.
//  Copyright (c) 2015 Adrian Siwy. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let phaseController = PhaseController()
    var lastUpdateTimeInterval: CFTimeInterval = 0
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
    
    override func didMoveToView(view: SKView) {
        
        // Set the scene size to the view size (make game window same as view window)
        size = view.frame.size
        
        // Add the parallax node to the GameScene
        addChild(phaseController.parallax)
        
        // Add the player to the staticLayer of Parallax
        phaseController.parallax.staticLayer.addChild(player.node)
        
//        //placeholder player
//        let playerPlaceholder = SKShapeNode(rectOfSize: CGSizeMake(size.width / 14, size.width / 14))
//        playerPlaceholder.position = CGPointMake(size.width / 2, 20)
//        addChild(playerPlaceholder)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            player.location = location
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch is moved */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            player.location = location
        }
    }
    
    // Keeps the scene syncronized
    func updateWithTimeSinceLastUpdate(elapsedTime: CFTimeInterval) {
        /* Called by the update method with the delta of the current and previous time intervals*/
        
        phaseController.iterateFrame(elapsedTime, flyingSpeed: player.flyingSpeed)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        // Find the elapsedTime and set the lastUpdateTimeInterval to the current time interval
        let elapsedTime: CFTimeInterval = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        
        // Call the new update method that takes the elapsedTime as a parameter. If lastUpdateTimeInterval is 0, then the update just started and there is no elapsedTime
        updateWithTimeSinceLastUpdate(elapsedTime > 1.0 ? 0 : elapsedTime)
    }
}
