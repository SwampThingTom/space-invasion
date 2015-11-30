//
//  Ship.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/8/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

enum MoveDirection: CGFloat {
    case Left = -1
    case None = 0
    case Right = 1
    
    func reverse() -> MoveDirection {
        switch (self) {
        case Left:
            return Right
        case Right:
            return Left
        case None:
            return None
        }
    }
}

class Ship: HittableSprite {
    
    private let explosionSound = SKAction.playSoundFileNamed("ship_explode", waitForCompletion: false)
    private let moveSpeed: CGFloat = 3.2 * 60
    
    var moveDirection = MoveDirection.None
    var active = true
    
    convenience init() {
        let texture = SKTexture(imageNamed: "Ship")
        self.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        self.physicsBody = SKPhysicsBody(rectangleOfSize: texture.size())
        self.physicsBody?.dynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Ship.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.InvaderMissile.rawValue
    }
    
    override required init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(deltaTime: CGFloat) {
        if !active {
            return
        }
        
        let minX = ScreenConstants.values.shipMinX
        let maxX = ScreenConstants.values.shipMaxX
        let moveDelta: CGFloat = moveDirection.rawValue * moveSpeed * deltaTime
        position.x = max(min(position.x + moveDelta, maxX), minX)
    }
    
    override func didGetHit(by sprite: SKSpriteNode, atPosition position: CGPoint) {
        runAction(explosionSound)
        showShipExplosion()
    }
    
    private func showShipExplosion() {
        active = false
        runAction(SKAction.sequence([
            SKAction.setTexture(SKTexture(imageNamed: "ShipBoom")),
            SKAction.waitForDuration(2),
            SKAction.setTexture(SKTexture(imageNamed: "Ship")),
            SKAction.runBlock() { self.active = true }]))
    }
}