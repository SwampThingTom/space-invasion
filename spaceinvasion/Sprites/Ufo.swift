//
//  Ufo.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 12/6/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

class Ufo: HittableSprite {
    
    private let moveSpeed: CGFloat = 2.5 * 60
    private var moveDirection = MoveDirection.None
    
    private(set) var score: Int = 0
    
    convenience init() {
        let texture = SKTexture(imageNamed: "Ufo")
        self.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        self.zPosition = ScreenConstants.values.ufoZPosition
        self.physicsBody = SKPhysicsBody(rectangleOfSize: texture.size())
        self.physicsBody?.dynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Ufo.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.ShipMissile.rawValue
    }
    
    override required init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        // TODO: play ufo sound while on screen
        moveDirection = random() < 0.5 ? .Left : .Right
        let x = moveDirection == .Left ? ScreenConstants.values.ufoMaxX : ScreenConstants.values.ufoMinX
        position = CGPoint(x: x, y: ScreenConstants.values.ufoY)
    }
    
    func update(deltaTime: CGFloat) {
        if self.parent == nil {
            return
        }
        
        let moveDelta: CGFloat = moveDirection.rawValue * moveSpeed * deltaTime
        position.x += moveDelta
        
        if position.x < ScreenConstants.values.ufoMinX || position.x > ScreenConstants.values.ufoMaxX {
            removeFromParent()
        }
    }
    
    override func didGetHit(by sprite: SKSpriteNode, atPosition position: CGPoint) {
        // TODO: Play sound, show score value
        determineScore()
        removeFromParent()
    }
    
    private func determineScore() {
        // TODO: Consider using a pattern for ufo score instead of a random number
        let chance: CGFloat = random()
        switch chance {
        case 0 ..< 0.05:       //  5%
            score = 300
        case 0.05 ..< 0.25:    // 20%
            score = 150
        case 0.2 ..< 0.75:     // 50%
            score = 100
        default:               // 25%
            score = 50
        }
    }
}