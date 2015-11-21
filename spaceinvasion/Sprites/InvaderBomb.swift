//
//  InvaderBomb.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/16/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

enum InvaderBombType {
    case Slow, Fast
    
    func speed() -> CGFloat {
        switch self {
        case Slow:
            return 240
        case Fast:
            return 360
        }
    }
    
    func texture() -> SKTexture {
        switch self {
        case Slow:
            return SKTexture(imageNamed: "Bomb_1")
        case Fast:
            return SKTexture(imageNamed: "Bomb_2")
        }
    }
}

class InvaderBomb: SKSpriteNode {
    
    private var type: InvaderBombType = .Slow
    
    convenience init(type: InvaderBombType) {
        let texture = type.texture()
        self.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        self.type = type
        self.physicsBody = SKPhysicsBody(rectangleOfSize: texture.size())
        self.physicsBody?.dynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.InvaderMissile.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        let contactBitMask = PhysicsCategory.Ship.rawValue | PhysicsCategory.ShipMissile.rawValue
        self.physicsBody?.contactTestBitMask = contactBitMask
    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(deltaTime: CGFloat) {
        let moveDelta: CGFloat = type.speed() * deltaTime
        position.y -= moveDelta
        
        if position.y < ScreenConstants.values.shipY {
            removeFromParent()
        }
    }
}