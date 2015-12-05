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
        return invaders.haveInvaded
    }
    
    private let invaders = Invaders()
    private let shields: [Shield]
    private let shipMissile = ShipMissile()
    private let ship = Ship()
    
    // TODO: Implement UFOs
    
    override init() {
        shields = PlayArea.createShields()
        super.init()
        addBackground()
        addShields()
        initializeInvaders()
        
        #if DEBUG_SHOW_PLAY_AREA_VIEWS
        addDebugViews()
        #endif
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addBackground() {
        let background = SKSpriteNode(imageNamed: ScreenConstants.values.backgroundImageName)
        background.position = CGPoint(
            x: ScreenConstants.values.playableWidth / 2,
            y: ScreenConstants.values.playableHeight / 2)
        background.zPosition = ScreenConstants.values.backgroundZPosition
        addChild(background)
    }
    
    private func addShields() {
        shields.forEach() { addChild($0) }
    }
    
    private func initializeInvaders() {
        invaders.setupNextInvasionLevel()
    }
    
    private class func createShields() -> [Shield] {
        let numShields = ScreenConstants.values.numShields
        let shieldWidth = ScreenConstants.values.shieldWidth
        let shieldRegionWidth = ScreenConstants.values.shipMaxX - ScreenConstants.values.shipMinX
        let shieldOffset = (shieldRegionWidth - shieldWidth * CGFloat(numShields)) / CGFloat(numShields + 1) + shieldWidth
        
        var shields = [Shield]()
        var shieldX = ScreenConstants.values.shipMinX - shieldWidth / 2 + shieldOffset
        for _ in 0 ..< ScreenConstants.values.numShields {
            let shield = Shield()
            shield.position = CGPoint(x: shieldX, y: ScreenConstants.values.shieldY)
            shields.append(shield)
            shieldX += shieldOffset
        }
        
        return shields
    }
    
    // MARK: - Level setup
    
    func startGame() {
        showInvaders()
        prepareShip()
    }
    
    private func showInvaders() {
        addChild(invaders)
    }
    
    private func prepareShip() {
        runAction(SKAction.sequence([
            SKAction.waitForDuration(2),
            SKAction.runBlock() { self.showShip() }]))
    }
    
    private func showShip() {
        ship.position = CGPoint(x: ScreenConstants.values.shipMinX, y: ScreenConstants.values.shipY)
        addChild(ship)
        invaders.canDropBombs = true
    }
    
    func setupNextInvasionLevel() {
        invaders.setupNextInvasionLevel()
    }
    
    // MARK: - Game loop
    
    func update(deltaTime: CGFloat) {
        updateControls()
        ship.update(deltaTime)
        shipMissile.update(deltaTime)
        invaders.update(deltaTime)
    }
    
    private func updateControls() {
        guard let controller = controller as GameControlling! else {
            return
        }
        ship.moveDirection = moveDirectionForController(controller)
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
        if ship.parent == nil || shipMissile.parent != nil {
            return
        }
        shipMissile.fire(ship.position)
        addChild(shipMissile)
    }
    
    // MARK: - Physics contact delegate
    
    func didBeginContact(contact: SKPhysicsContact) {
        // TODO: Need to track when invaders remain in contact with shields... not just when they begin contact
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
    
    private func invaderWasHit(invader: Invader, by sprite: SKSpriteNode, atPosition position: CGPoint) {
        invaders.invaderWasHit(invader)
        scoreKeeper?.addToScore(invader.score)
        
        if invaders.destroyed {
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
        
        waitForShipExplosionToComplete()
    }
    
    private func waitForShipExplosionToComplete() {
        invaders.waitingForShipExplosion = true
        runAction(SKAction.sequence([
            SKAction.waitForDuration(3),
            SKAction.runBlock() {
                self.showShip()
                self.invaders.waitingForShipExplosion = false
            }]))
    }
    
    private func shieldWasHit(shield: Shield, by sprite: SKSpriteNode, atPosition position: CGPoint) {
        shield.didGetHit(by: sprite, atPosition: position)
        
        if let hittableSprite = sprite as? Hittable {
            hittableSprite.didGetHit(by: shield, atPosition: position)
        }
    }
    
    // MARK: - Debug
        
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