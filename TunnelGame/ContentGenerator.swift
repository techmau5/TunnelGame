//
//  ContentGenerator.swift
//  TunnelGame
//
//  Created by Adrian Siwy on 7/18/16.
//  Copyright © 2016 Adrian Siwy. All rights reserved.
//

import SpriteKit

/* How these classes function together
 1) Generate content
 2) Cycle through details in loop
    a) Send Size of detail to the Region
        1) Region cycles through each Subregion and creates a new array of placement Subregions
        2) Determines the total width of the placement Subregions
        3) Picks a random number (x) from the total width
        4) Determines which Subregion (original) it corresponds with
        5) Picks a random number (y) from region (height - detail height)
        6) Splits the region that the detail was placed into
        7) Returns the (x,y) coordinate to Detail Generator
    b) Place the detail at the coordinate
 3) Prepare the Content Node to be added to the Parallax
 */

// Details are generated on second thread here
class ContentGenerator {
    static let region = Region()
    static let contentAtlas = SKTextureAtlas(named: "Content")
    
    class func generateMainLayerContent() -> Content {
        
        //pick a random background texture
        let background = SKSpriteNode(texture: contentAtlas.textureNamed("bgtest2"))
        background.texture?.filteringMode = .nearest
        background.anchorPoint = CGPoint(x: 0, y: 0)
        
        //pick random side bars
        let rightBar = SKSpriteNode(texture: contentAtlas.textureNamed("rightbar"))
        rightBar.texture?.filteringMode = .nearest
        rightBar.anchorPoint = CGPoint(x: 1, y: 0)
        rightBar.position = CGPoint(x: 90, y: 0)
        
        let leftBar = SKSpriteNode(texture: contentAtlas.textureNamed("leftbar"))
        leftBar.texture?.filteringMode = .nearest
        leftBar.anchorPoint = CGPoint(x: 0, y: 0)
        
        //create a content node with the generated nodes
        let newContent = Content(background: background, rightSide: rightBar, leftSide: leftBar)
        
        //generate 3 randomly sized details at random points and add them to newContent's detailArray
        var totalSpace = 4.0
        for _ in 0...2 {
            if totalSpace > 1.0 {
                let detailType = arc4random_uniform(UInt32(totalSpace + 0.5))
                
                //if detailType is not 0 (nothing), generate a detail
                if detailType != 0 {
                    let newDetail: SKSpriteNode
                    switch detailType {
                    case 1:
                        //generate small detail
                        newDetail = generateDetail(texture: contentAtlas.textureNamed("DSt"))
                        totalSpace -= 0.5
                        break
                    case 2:
                        //generate medium detail
                        newDetail = generateDetail(texture: contentAtlas.textureNamed("DMt"))
                        totalSpace -= 1.5
                        break
                    case 3:
                        //generate large detail
                        newDetail = generateDetail(texture: contentAtlas.textureNamed("DLt"))
                        totalSpace -= 2.5
                        break
                    default:
                        newDetail = SKSpriteNode()
                        break
                    }
                    
                    // add the generated detail to the array
                    newContent.detailArray.append(newDetail)
                }
            } else {
                break
            }
        }
        
        //add the details to the node
        newContent.addDetails()
        
        return newContent
    }
    
    class func generateLayerContent() -> Content {
        return Content()
    }
    
    // generate a newDetail with a given texture
    class func generateDetail(texture: SKTexture) -> SKSpriteNode {
        
        let newDetail = SKSpriteNode(texture: texture)
        
        // use Region to get a random position with no overlapping details
        newDetail.position = region.getPlacementCoordinate(newDetail.size)
        
        return newDetail
    }
}

// ContentNode is requested by the ParallaxLayer and added to a DetailPiece
class Content {
    let node = SKNode()
    var detailArray: [SKSpriteNode] = []
    
    init() {
        
    }
    
    init(background: SKSpriteNode, rightSide: SKSpriteNode, leftSide: SKSpriteNode) {
        
        //add everything in content to the main node
        node.addChild(background)
        node.addChild(rightSide)
        node.addChild(leftSide)
    }
    
    func addDetails() {
        
        for detail in detailArray {
            node.addChild(detail)
        }
    }
}

// Keeps track of where details can be placed on the piece by determining available space
// See "Regions" in Notebook
class Region {
    
    var height = 40
    var subregions: [Subregion] = []
    
    init() {
        // 90 should be replaced with the correct region width excluding the side bars
        let defaultSubregion = Subregion.init(leftX: 0, rightX: 90)
        subregions.append(defaultSubregion)
    }
    
    // Called by DetailGenerator, gives a random (x,y) coordinate for a detail of given size
    func getPlacementCoordinate(_ detailSize: CGSize) -> CGPoint {
        // Calculate Placement Subregions
        var pSubregions: [Subregion] = []
        var placementWidth = 0
        
        for subregion in subregions {
            // If the subregion is atleast the width of the detail
            if subregion.width >= Int(detailSize.width) {
                // Create a placement Subregion with bounds specific to the detail
                let pSubregion = Subregion.init(leftX: subregion.leftBound, rightX: subregion.rightBound - Int(detailSize.width))
                pSubregions.append(pSubregion)
                // Add the Subregion width to the placement width
                placementWidth += Int(pSubregion.width)
            }
        }
        
        // Generate a random (x) value within the bounds of the Placement Subregions
        var randomX = Int(arc4random_uniform(UInt32(placementWidth + 1)))
        
        var selectedRegion = 0
        for psubregion in pSubregions {
            if psubregion.width < randomX {
                // in subregion
                for subregion in subregions {
                    if subregion.leftBound == psubregion.leftBound {
                        // same subregion
                        break
                    }
                    selectedRegion += 1
                }
            } else {
                randomX -= psubregion.width
            }
        }
        
        // Calculate the (x) coordinate
        let xCoordinate = CGFloat(subregions[selectedRegion].leftBound + randomX)
        
        // Calculate the (y) coordinate
        let placementHeight = height - Int(detailSize.height)
        let yCoordinate = CGFloat(Int(arc4random_uniform(UInt32(placementHeight + 1))))
        
        // Split the subregion detail was placed into
        splitSubregion(selectedRegion, xPosition: xCoordinate, detailWidth: detailSize.width)
        
        // Return the random coordinate to DetailGenerator
        return CGPoint(x: xCoordinate, y: yCoordinate)
    }
    
    // Split the Subregion and replace it in the array with its two halves
    func splitSubregion(_ srPosition: Int, xPosition: CGFloat, detailWidth: CGFloat) {
        let startX = subregions[srPosition].leftBound
        let endX = subregions[srPosition].rightBound
        
        let leftHalf = Subregion.init(leftX: startX, rightX: Int(xPosition))
        let rightHalf = Subregion.init(leftX: Int(xPosition) + Int(detailWidth), rightX: endX)
        
        subregions.remove(at: srPosition)
        if leftHalf.width > 3 {
            subregions.append(leftHalf)
        }
        if rightHalf.width > 3 {
            subregions.append(rightHalf)
        }
    }
}

// The Region will be split into Subregions
class Subregion {
    
    let leftBound: Int
    let rightBound: Int
    var width: Int {
        get{
            return rightBound - leftBound
        }
    }
    
    init(leftX: Int, rightX: Int) {
        leftBound = leftX
        rightBound = rightX
    }
}
