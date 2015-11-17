//
//  ShipMissileSpriteNode.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/8/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

class ShipMissileSpriteNode: SKSpriteNode {
    
    private let missileFiredSound = SKAction.playSoundFileNamed("ship_fire", waitForCompletion: false)
    private let moveSpeed: CGFloat = 6 * 60

    private(set) var active = false
    
    convenience init() {
        let texture = SKTexture(imageNamed: "Missile")
        self.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        self.physicsBody = SKPhysicsBody(rectangleOfSize: texture.size())
        self.physicsBody?.dynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.ShipMissile.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Invader.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fire(position: CGPoint) {
        self.position = position
        active = true
        runAction(missileFiredSound)
    }
    
    func remove() {
        active = false
        removeFromParent()
    }
    
    func update(deltaTime: CGFloat) {
        if !active {
            return
        }
        
        let moveDelta: CGFloat = moveSpeed * deltaTime
        position.y += moveDelta
        
        if position.y > ScreenConstants.values.shipMissileMaxY {
            remove()
        }
    }
}
