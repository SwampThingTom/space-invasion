//
//  GameScene.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/8/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

enum PhysicsCategory: UInt32 {
    case None = 0x00
    case Ship = 0x01
    case ShipMissile = 0x02
    case Invader = 0x04
    case InvaderMissile = 0x08
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // TODO: Move to a plist file
    private let shipHorizontalMargin: CGFloat = 108
    private let shipY: CGFloat = 100
    private let playableAreaMaxY: CGFloat = 705
    private let invadersHorizontalMargin: CGFloat = 72
    private let invadersMinY: CGFloat = 135
    private let invadersMaxY: CGFloat = 605
    
    private var background: SKSpriteNode?
    private var ship: ShipSpriteNode?
    private var shipMissile: ShipMissileSpriteNode?
    private var invaders: Invaders?
    
    private var level = 1
    private var lastUpdateTime: CGFloat = 0
    
    // MARK: View lifecycle
    
    override func didMoveToView(view: SKView) {
        addPhysics()
        addBackground()
        addShip()
        addInvaders()
        addControlsToView(view)
        
        if Settings.debug {
            addDebugViews()
        }
        
        // TODO: Start playing music
    }
    
    override func willMoveFromView(view: SKView) {
        // TODO: Stop playing music
    }
    
    private func addPhysics() {
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
    }
    
    private func addBackground() {
        backgroundColor = SKColor.blackColor()
        background = SKSpriteNode(imageNamed: "Background")
        background!.position = CGPoint(x: size.width/2, y: size.height/2)
        background!.zPosition = -1
        addChild(background!)
    }
    
    private func addShip() {
        ship = ShipSpriteNode(
            minX: shipHorizontalMargin,
            maxX: background!.size.width - shipHorizontalMargin)
        ship!.position = CGPoint(x: shipHorizontalMargin, y: shipY)
        addChild(ship!)
        shipMissile = ShipMissileSpriteNode(maxY: playableAreaMaxY)
    }
    
    private func addInvaders() {
        invaders = Invaders(
            minX: invadersHorizontalMargin,
            maxX: background!.size.width - invadersHorizontalMargin,
            minY: invadersMinY,
            maxY: invadersMaxY)
        invaders!.setupInvasionForLevel(level)
        addChild(invaders!)
    }
    
    private func addControlsToView(view: SKView) {
        let fireButtonGestureRecognizer = UITapGestureRecognizer(target: self, action: "fireButtonPressed")
        fireButtonGestureRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
        view.addGestureRecognizer(fireButtonGestureRecognizer)
    }
    
    private func addDebugViews() {
        debugAddRect(CGRect(
            x: invadersHorizontalMargin,
            y: invadersMinY,
            width: background!.size.width - 2 * invadersHorizontalMargin,
            height: invadersMaxY - invadersMinY))
        
        debugAddRect(CGRect(
            x: shipHorizontalMargin,
            y: shipY - ship!.size.height / 2,
            width: background!.size.width - 2 * shipHorizontalMargin,
            height: ship!.size.height))
    }
    
    // MARK: Input handling
    
    var touchStartLocation = CGPointZero
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        touchStartLocation = touch.locationInNode(self)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchEpsilon: CGFloat = 60
        let touchLocation = touch.locationInNode(self)
        
        if touchLocation.x < touchStartLocation.x - touchEpsilon {
            ship?.moveDirection = .Left
        }
        else if touchLocation.x > touchStartLocation.x + touchEpsilon {
            ship?.moveDirection = .Right
        }
        else {
            ship?.moveDirection = .None
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        ship?.moveDirection = .None
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        ship?.moveDirection = .None
    }
    
    func fireButtonPressed() {
        if shipMissile!.active {
            return
        }
        
        shipMissile!.fire(ship!.position)
        addChild(shipMissile!)
    }
    
    // MARK: Game loop
    
    override func update(currentTime: CFTimeInterval) {
        let deltaTime: CGFloat = lastUpdateTime > 0 ? CGFloat(currentTime) - lastUpdateTime : 0.0
        lastUpdateTime = CGFloat(currentTime)
        ship?.update(deltaTime)
        shipMissile?.update(deltaTime)
        invaders?.update(deltaTime)
    }

    // MARK: Physics contact delegate

    func didBeginContact(contact: SKPhysicsContact) {
        guard let invader = contact.bodyA.node as! InvaderSpriteNode! else {
            return
        }
        guard let missile = contact.bodyB.node as! ShipMissileSpriteNode! else {
            return
        }
        invaderWasHit(invader, byMissile: missile)
    }

    private func invaderWasHit(invader: InvaderSpriteNode!, byMissile missile: ShipMissileSpriteNode!) {
        invaders?.invaderWasHit(invader)
        missile.remove()
    }

    // MARK: Debug
    
    private func debugAddRect(rect: CGRect) {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, rect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
}
