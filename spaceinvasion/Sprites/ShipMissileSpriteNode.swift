//
//  ShipMissileSpriteNode.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/8/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

class ShipMissileSpriteNode: SKSpriteNode {
    
    private let missileFiredSound = SKAction.playSoundFileNamed("ship_fire", waitForCompletion: false)
    private let maxY: CGFloat
    private let moveSpeed: CGFloat = 6 * 60
    
    private(set) var active = false
    
    init(maxY: CGFloat) {
        self.maxY = maxY
        let texture = SKTexture(imageNamed: "Missile")
        super.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fire(position: CGPoint) {
        self.position = position
        active = true
        runAction(missileFiredSound)
    }
    
    func update(deltaTime: CGFloat) {
        if !active {
            return
        }
        
        let moveDelta: CGFloat = moveSpeed * deltaTime
        position.y += moveDelta
        
        if position.y > maxY {
            active = false
            removeFromParent()
        }
    }
}
