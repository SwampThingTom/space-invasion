//
//  SKSpriteNode+Debug.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 12/2/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

extension SKSpriteNode {
    
    /// Adds a red dot at the given position.
    ///
    /// - Parameter position: The position of the dot in the sprite's coordinate space.
    
    private func debugShowPosition(position: CGPoint) {
        let contactSprite = SKSpriteNode(color: SKColor.redColor(), size: CGSizeMake(5, 5))
        contactSprite.position = position
        contactSprite.zPosition = 100
        addChild(contactSprite)
    }
    
    /// Adds a rectangle showing the bounds of the given sprite.
    ///
    /// - Parameter sprite: The sprite whose bounding rectangle is to be shown.
    
    private func debugShowSpriteBoundingRectangle(sprite: SKSpriteNode) {
        let boundingRectangle = SKShapeNode(rectOfSize: sprite.size)
        boundingRectangle.strokeColor = SKColor.blueColor()
        boundingRectangle.position = sprite.position
        boundingRectangle.zPosition = 90
        sprite.parent?.addChild(boundingRectangle)
    }
}