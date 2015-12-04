//
//  SKNode+Debug.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 12/2/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

extension SKNode {
    
    /// Adds a red dot at the given position. Useful for showing physics contact position, among other things.
    ///
    /// - Parameter position: The position of the dot in this node's coordinate space.
    
    func debugShowPosition(position: CGPoint) {
        let contactSprite = SKSpriteNode(color: SKColor.redColor(), size: CGSizeMake(5, 5))
        contactSprite.position = position
        contactSprite.zPosition = 100
        addChild(contactSprite)
    }
    
    /// Adds a red rectangle.
    ///
    /// - Parameter rect: The origin and size of the rectangle to show in this node's coordinate space.
    
    func debugShowRect(rect: CGRect) {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, rect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        shape.zPosition = 80
        addChild(shape)
    }
    
    /// Adds a rectangle showing the bounds of the given sprite.
    ///
    /// - Parameter sprite: The sprite whose bounding rectangle is to be shown.
    
    func debugShowSpriteBoundingRectangle(sprite: SKSpriteNode) {
        let boundingRectangle = SKShapeNode(rectOfSize: sprite.size)
        boundingRectangle.strokeColor = SKColor.blueColor()
        boundingRectangle.position = sprite.position
        boundingRectangle.zPosition = 90
        sprite.parent?.addChild(boundingRectangle)
    }
}