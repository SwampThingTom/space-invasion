//
//  ShipMissile.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/8/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

class ShipMissile: HittableSprite {
    
    private let missileFiredSound = SKAction.playSoundFileNamed("ship_fire", waitForCompletion: false)
    private let moveSpeed: CGFloat = 6 * 60
    
    convenience init() {
        let texture = SKTexture(imageNamed: "Missile")
        self.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        self.zPosition = ScreenConstants.values.missileZPosition
        self.physicsBody = SKPhysicsBody(rectangleOfSize: texture.size())
        self.physicsBody?.dynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.ShipMissile.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        let contactBitMask = PhysicsCategory.Invader.rawValue | PhysicsCategory.Ufo.rawValue | PhysicsCategory.Shield.rawValue | PhysicsCategory.InvaderMissile.rawValue
        self.physicsBody?.contactTestBitMask = contactBitMask
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fire(position: CGPoint) {
        let offset = CGPoint(x: size.width / 2, y: 0)
        self.position = position + offset
        runAction(missileFiredSound)
    }
    
    func update(deltaTime: CGFloat) {
        if parent == nil {
            return
        }
        
        let moveDelta: CGFloat = moveSpeed * deltaTime
        position.y += moveDelta
        
        if position.y > ScreenConstants.values.shipMissileMaxY {
            remove()
        }
    }
    
    override func didGetHit(by sprite: SKSpriteNode, atPosition position: CGPoint) {
        remove()
    }
    
    private func remove() {
        removeFromParent()
    }
}