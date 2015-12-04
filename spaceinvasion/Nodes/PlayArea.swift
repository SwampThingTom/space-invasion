//
//  PlayArea.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/15/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

enum PhysicsCategory: UInt32 {
    case None = 0x00
    case Ship = 0x01
    case Invader = 0x02
    case Ufo = 0x04
    case Shield = 0x08
    
    // Missiles range from 0x10 - 0xF0
    case ShipMissile = 0x10
    case InvaderMissile = 0x20
    case AnyMissile = 0xF0
}

protocol ScoreKeeping {
    func addToScore(score: Int)
    func shipDestroyed()
    func invadersDestroyed()
}

class PlayArea : SKNode, SKPhysicsContactDelegate {
        
    var controller: GameControlling?
    var scoreKeeper: ScoreKeeping?
    
    var invaded: Bool {
        return invaders!.haveInvaded
    }
    
    // TODO: Consider creating these in init so we don't have to deal with optionals
    private var background: SKSpriteNode?
    private var ship: Ship?
    private var shipMissile: ShipMissile?
    private var invaders: Invaders?
    private var shields: [Shield]?
    
    // TODO: Implement UFOs
    
    override init() {
        super.init()
        addBackground()
        addShip()
        addInvaders()
        addShields()
        
        #if DEBUG_SHOW_PLAY_AREA_VIEWS
        addDebugViews()
        #endif
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addBackground() {
        background = SKSpriteNode(imageNamed: ScreenConstants.values.backgroundImageName)
        background?.position = CGPoint(
            x: ScreenConstants.values.playableWidth / 2,
            y: ScreenConstants.values.playableHeight / 2)
        background!.zPosition = -1
        addChild(background!)
    }
    
    private func addShip() {
        ship = Ship()
        ship!.position = CGPoint(x: ScreenConstants.values.shipMinX, y: ScreenConstants.values.shipY)
        addChild(ship!)
        shipMissile = ShipMissile()
    }
    
    private func addInvaders() {
        invaders = Invaders()
        invaders!.setupNextInvasionLevel()
        addChild(invaders!)
    }
    
    private func addShields() {
        let numShields = ScreenConstants.values.numShields
        let shieldWidth = ScreenConstants.values.shieldWidth
        let playableWidth = ScreenConstants.values.playableWidth
        let shieldOffset = (playableWidth - shieldWidth * CGFloat(numShields)) / CGFloat(numShields + 1) + shieldWidth
        
        shields = [Shield]()
        var shieldX = shieldOffset
        for _ in 0 ..< ScreenConstants.values.numShields {
            let shield = Shield()
            shield.position = CGPoint(x: shieldX, y: ScreenConstants.values.shieldY)
            shieldX += shieldOffset
            shields?.append(shield)
            addChild(shield)
        }
    }
    
    // MARK: - Level setup
    
    func setupNextInvasionLevel() {
        invaders!.setupNextInvasionLevel()
    }
    
    // MARK: - Game loop
    
    func update(deltaTime: CGFloat) {
        updateControls()
        ship?.update(deltaTime)
        shipMissile?.update(deltaTime)
        invaders?.update(deltaTime)
    }
    
    private func updateControls() {
        guard let controller = controller as GameControlling! else {
            return
        }
        ship?.moveDirection = moveDirectionForController(controller)
        if controller.fireButtonIsPressed {
            fire()
        }
    }
    
    private func moveDirectionForController(controller: GameControlling) -> MoveDirection {
        if controller.leftButtonIsPressed {
            return .Left
        }
        if controller.rightButtonIsPressed {
            return .Right
        }
        return .None
    }
    
    private func fire() {
        if !ship!.active {
            return
        }
        
        if shipMissile!.active {
            return
        }
        
        shipMissile!.fire(ship!.position)
        addChild(shipMissile!)
    }
    
    // MARK: - Physics contact delegate
    
    func didBeginContact(contact: SKPhysicsContact) {
        if let contactObjects: (shield: Shield, collider: SKSpriteNode) = spriteThatMadeContact(contact) {
            shieldWasHit(contactObjects.shield, by: contactObjects.collider, atPosition: contact.contactPoint)
        }
        else if let contactObjects: (invader: Invader, collider: SKSpriteNode) = spriteThatMadeContact(contact) {
            invaderWasHit(contactObjects.invader, by: contactObjects.collider, atPosition: contact.contactPoint)
        }
        else if let contactObjects: (ship: Ship, collider: SKSpriteNode) = spriteThatMadeContact(contact) {
            shipWasHit(contactObjects.ship, by: contactObjects.collider, atPosition: contact.contactPoint)
        }
        else if let hittableSpriteA = contact.bodyA.node as? HittableSprite, let hittableSpriteB = contact.bodyB.node as? HittableSprite {
            hittableSpriteA.didGetHit(by: hittableSpriteB, atPosition: contact.contactPoint)
            hittableSpriteB.didGetHit(by: hittableSpriteA, atPosition: contact.contactPoint)
        }
    }
    
    private func spriteThatMadeContact<T: SKSpriteNode>(contact: SKPhysicsContact) -> (T, SKSpriteNode)? {
        if let sprite = contact.bodyA.node as? T, let collider = contact.bodyB.node as? SKSpriteNode {
            return (sprite, collider)
        }
        if let sprite = contact.bodyB.node as? T, let collider = contact.bodyA.node as? SKSpriteNode {
            return (sprite, collider)
        }
        return nil
    }
    
    private func shieldWasHit(shield: Shield, by sprite: SKSpriteNode, atPosition position: CGPoint) {
        if !shield.wasHit(by: sprite, atPosition: position) {
            return
        }
        
        shield.didGetHit(by: sprite, atPosition: position)
        
        if let hittableSprite = sprite as? Hittable {
            hittableSprite.didGetHit(by: shield, atPosition: position)
        }
    }
    
    private func invaderWasHit(invader: Invader, by sprite: SKSpriteNode, atPosition position: CGPoint) {
        invaders!.invaderWasHit(invader)
        scoreKeeper?.addToScore(invader.score)
        
        if invaders!.destroyed {
            scoreKeeper?.invadersDestroyed()
        }
        
        if let hittableSprite = sprite as? Hittable {
            hittableSprite.didGetHit(by: invader, atPosition: position)
        }
    }
    
    private func shipWasHit(ship: Ship, by sprite: SKSpriteNode, atPosition position: CGPoint) {
        ship.didGetHit(by: sprite, atPosition: position)
        scoreKeeper?.shipDestroyed()
        
        if let hittableSprite = sprite as? Hittable {
            hittableSprite.didGetHit(by: ship, atPosition: position)
        }
    }
    
    /// MARK: - Debug
        
    #if DEBUG_SHOW_PLAY_AREA_VIEWS
    private func addDebugViews() {
        debugShowRect(CGRect(
            x: ScreenConstants.values.invadersMinX,
            y: ScreenConstants.values.invadersMinY,
            width: ScreenConstants.values.invadersMaxX - ScreenConstants.values.invadersMinX,
            height: ScreenConstants.values.invadersMaxY - ScreenConstants.values.invadersMinY))
        
        debugShowRect(CGRect(
            x: ScreenConstants.values.shipMinX,
            y: ScreenConstants.values.shipY - ship!.size.height / 2,
            width: ScreenConstants.values.playableWidth - 2 * ScreenConstants.values.shipMinX,
            height: ship!.size.height))
    }
    #endif
}