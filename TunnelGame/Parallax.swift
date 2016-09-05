//
//  Parallax.swift
//  TunnelGame
//
//  Created by Adrian Siwy on 7/4/16.
//  Copyright © 2016 Adrian Siwy. All rights reserved.
//

import SpriteKit

class Parallax: SKNode {
    
    static let screenHeight = UIScreen.mainScreen().applicationFrame.height
    static var piecesOnScreen = 4
    var cycleLimit = 10 // <- must be even to ensure that the nodes will all be alligned
    var cycleCount = 0
    var currentCycleCount = 0
    let bgLayer = ParallaxLayer(type: .BackgroundLayer)
    let mainLayer = MainParallaxLayer(type: .MainLayer)
    let fgLayer = ParallaxLayer(type: .ForegroundLayer)
    let staticLayer = SKNode() // <- moves upward when the moving layers deccelerate
    
    // Set the layer Z positions
    override init() {
        
        super.init()
        
        // Set the appropriate z positions for each layer (background is actually on top of the mainlayer -> see TextureGenerator)
        bgLayer.zPosition = 1
        mainLayer.zPosition = 0
        staticLayer.zPosition = 2
        fgLayer.zPosition = 3
        
        // Add the children to the parallax
        addChild(mainLayer)
        addChild(staticLayer)
        addChild(fgLayer)
        
        // Add the bgLayer to the mainLayer -> bgCropNode
        mainLayer.bgCropNode.addChild(bgLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Reset the positions and contents of the parallax layers
    func resetParallaxLayers() {
        
        bgLayer.resetDetailPieceArray()
        mainLayer.resetDetailPieceArray()
        //MIGHT CHANGE FOREGROUND FUNCTIONALITY
        fgLayer.resetDetailPieceArray()
    }
    
    // Moves each layer based on the elapsedTime
    func continueCycle(elapsedTime: CFTimeInterval, playerSpeed: Double) -> Bool {
        
        // The travelDistance is calculated using the timeElapsed the height of one cycle (screen height) and the currentPhaseSpeed (number of cycles per second)
        let travelDistance: CGFloat = CGFloat(Double(Parallax.screenHeight) * elapsedTime) * CGFloat(playerSpeed)
        
        // Move the layers by the travelDistance; the backgroundLayer moves 1/2x normal and the foregroundLayer moves 2x normal
        bgLayer.moveLayers(travelDistance/2)
        fgLayer.moveLayers(travelDistance*2)
        
        // Move the mainLayer and add to cycleCount if a mainLayer piece was moved to the top
        if mainLayer.moveLayers(travelDistance) {
            cycleCount += 1
        }
        
        // If the mainLayer has performed the number of max cycles, return true
        if cycleCount >= cycleLimit {
            return true
        }
        else {
            return false
        }
    }
}

class ParallaxLayer: SKNode {
    
    var detailPieceArray: [DetailPiece] = []
    let layerType: LayerType
    
    // Add methods for reset and movement
    init(type: LayerType) {
        
        layerType = type
        
        super.init()
        
        // Generate the DetailPieces
        generateDetailPieces()
    }
    
    // Generate the DetailPieces to put into the array
    // Give them a location and populate them
    private func generateDetailPieces() {
        
        for i in 0..<(Parallax.piecesOnScreen + 2) {
            let newPosition = Parallax.screenHeight * CGFloat(0.25 * Double(i))
            let newPiece = DetailPiece(yPosition: newPosition)
            detailPieceArray.append(newPiece)
            addChild(newPiece.contentNode)
            // Request Initial Nodes from DetailGenerator
        }
    }
    
    // Remove the current set of detail pieces and generate new ones
    func resetDetailPieceArray() {
        
        detailPieceArray.removeAll()
        generateDetailPieces()
    }
    
    // Move the pieces based on the distance given, if a piece was moved to the top, return true
    func moveLayers(distance: CGFloat) -> Bool {
        
        var wasMovedToTop = false
        
        for piece in detailPieceArray {
            piece.yPosition -= distance
            // Check to see if the node is to be moved back to the top
            // The piece is moved to the top if it goes completely off screen
            if piece.yPosition <= -0.25 * Parallax.screenHeight {
                piece.yPosition += 1.5 * Parallax.screenHeight
                wasMovedToTop = true
                // Request the DetailGenerator to populate the Piece
                piece.requestNewNodes()
            }
        }
        
        return wasMovedToTop
    }
    
    //required code, won't be used
    required init?(coder aDecoder: NSCoder) {
        layerType = .NullLayer
        super.init(coder: aDecoder)
    }
}

class MainParallaxLayer: ParallaxLayer {
    
    let bgCropNode = SKCropNode()
    let bgMaskNode = SKNode()
    
    override init(type: LayerType) {
        
        super.init(type: type)
        
        // Add the mask to the SKCropNode and add the node to the Layer
        bgCropNode.maskNode = bgMaskNode
        addChild(bgCropNode)
    }
    
    override func generateDetailPieces() {
        for i in 0..<(Parallax.piecesOnScreen + 2) {
            let newPosition = Parallax.screenHeight * CGFloat(0.25 * Double(i))
            let newPiece = MaskedDetailPiece(yPosition: newPosition)
            detailPieceArray.append(newPiece)
            addChild(newPiece.contentNode)
            bgMaskNode.addChild(newPiece.maskNode)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// DetailPieces make up the detail on the layers
class DetailPiece {
    
    let contentNode = SKNode()
    var yPosition: CGFloat {
        set {
            contentNode.position.y = newValue
        }
        get {
            return contentNode.position.y
        }
    }
    
    init(yPosition: CGFloat) {
        self.yPosition = yPosition
    }
    
    func requestNewNodes() {
        
    }
}

class MaskedDetailPiece: DetailPiece {
    
    let maskNode = SKNode()
    override var yPosition: CGFloat {
        set {
            contentNode.position.y = newValue
            maskNode.position.y = newValue
        }
        get {
            return contentNode.position.y
        }
    }
}

enum LayerType {
    
    case BackgroundLayer
    case MainLayer
    case ForegroundLayer
    case NullLayer
}
