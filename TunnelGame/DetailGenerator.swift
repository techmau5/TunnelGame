//
//  DetailGenerator.swift
//  TunnelGame
//
//  Created by Adrian Siwy on 7/18/16.
//  Copyright © 2016 Adrian Siwy. All rights reserved.
//

import SpriteKit

/* How these classes function together
 1) Generate details
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
 3) Prepare the piece to be added to the Parallax
 */

// Details are generated on second thread here
class DetailGenerator {
    let region = Region()
    
    func generateDetail(width: CGFloat, height: CGFloat) -> CGPoint {
        
        let size = CGSizeMake(width, height)
        
        let coordinate = region.getPlacementCoordinate(size)
        
        return coordinate
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
    func getPlacementCoordinate(detailSize: CGSize) -> CGPoint {
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
        
        var sr = 0
        for subregion in subregions {
            if subregion.width >= Int(detailSize.width) {
                if subregion.width - Int(detailSize.width) >= randomX || subregions.count == sr + 1 {
                    break
                } else {
                    sr += 1
                    randomX -= subregion.width - Int(detailSize.width)
                }
            } else {
                sr += 1
            }
        }
        
        // Calculate the (x) coordinate
        let xCoordinate = CGFloat(subregions[sr].leftBound + randomX)
        
        // Caluclate the (y) coordinate
        let placementHeight = height - Int(detailSize.height)
        let yCoordinate = CGFloat(Int(arc4random_uniform(UInt32(placementHeight + 1))))
        
        // Split the subregion detail was placed into
        splitSubregion(sr, xPosition: xCoordinate, detailWidth: detailSize.width)
        
        // Return the random coordinate to DetailGenerator
        return CGPointMake(xCoordinate, yCoordinate)
    }
    
    // Split the Subregion and replace it in the array with its two halves
    func splitSubregion(srPosition: Int, xPosition: CGFloat, detailWidth: CGFloat) {
        let startX = subregions[srPosition].leftBound
        let endX = subregions[srPosition].rightBound
        
        let leftHalf = Subregion.init(leftX: startX, rightX: Int(xPosition))
        let rightHalf = Subregion.init(leftX: Int(xPosition) + Int(detailWidth), rightX: endX)
        
        subregions.removeAtIndex(srPosition)
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