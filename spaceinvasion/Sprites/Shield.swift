//
//  Shield.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/27/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

class Shield: HittableSprite {
    
    var image: CGImageRef
    
    convenience init() {
        let texture = SKTexture(imageNamed: "Shield")
        self.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        self.physicsBody = SKPhysicsBody(rectangleOfSize: texture.size())
        self.physicsBody?.dynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Shield.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.AnyMissile.rawValue
    }
    
    override required init(texture: SKTexture?, color: UIColor, size: CGSize) {
        image = texture!.CGImage
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func wasHit(by sprite: SKSpriteNode, atPosition position: CGPoint) -> Bool {
        
        // TODO: Implement determining whether shield was hit
        return true
    }
    
    override func didGetHit(by sprite: SKSpriteNode, atPosition position: CGPoint) {
        // TODO: Implement shield getting hit
    }
}