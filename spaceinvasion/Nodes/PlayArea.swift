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
    
    private let ufo = Ufo()
    private var ufoTimer: SKAction?
    private let invaders = Invaders()
    private let shields: [Shield]
    private let shipMissile = ShipMissile()
    private let ship = Ship()
    
    private var invaderShieldContacts = [(invader: Invader, shield: Shield)]()
    
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
        invaderShieldContacts.removeAll()
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
        startUfoTimer()
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
    
    private func startUfoTimer() {
        let timer = SKAction.sequence([
            SKAction.waitForDuration(25),
            SKAction.runBlock() { self.showUfo() }])
        runAction(SKAction.repeatActionForever(timer))
        ufoTimer = timer
    }
    
    private func showUfo() {
        ufo.start()
        addChild(ufo)
    }
    
    func setupNextInvasionLevel() {
        invaders.setupNextInvasionLevel()
    }
    
    // MARK: - Game loop
    
    func update(deltaTime: CGFloat) {
        updateControls()
        ufo.update(deltaTime)
        ship.update(deltaTime)
        shipMissile.update(deltaTime)
        invaders.update(deltaTime)
        updateInvaderShieldContacts()
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
        if let contactObjects: (shield: Shield, collider: SKSpriteNode) = spriteThatMadeContact(contact) {
            shieldWasHit(contactObjects.shield, by: contactObjects.collider, atPosition: contact.contactPoint)
        }
        else if let contactObjects: (invader: Invader, collider: SKSpriteNode) = spriteThatMadeContact(contact) {
            invaderWasHit(contactObjects.invader, by: contactObjects.collider, atPosition: contact.contactPoint)
        }
        else if let contactObjects: (ufo: Ufo, collider: SKSpriteNode) = spriteThatMadeContact(contact) {
            ufoWasHit(contactObjects.ufo, by: contactObjects.collider, atPosition: contact.contactPoint)
        }
        else if let contactObjects: (ship: Ship, collider: SKSpriteNode) = spriteThatMadeContact(contact) {
            shipWasHit(contactObjects.ship, by: contactObjects.collider, atPosition: contact.contactPoint)
        }
        else if let hittableSpriteA = contact.bodyA.node as? HittableSprite, let hittableSpriteB = contact.bodyB.node as? HittableSprite {
            hittableSpriteA.didGetHit(by: hittableSpriteB, atPosition: contact.contactPoint)
            hittableSpriteB.didGetHit(by: hittableSpriteA, atPosition: contact.contactPoint)
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        if let contactObjects: (shield: Shield, collider: SKSpriteNode) = spriteThatMadeContact(contact) {
            invaderShieldContacts = invaderShieldContacts.filter() { $0.invader != contactObjects.collider }
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
    
    private func ufoWasHit(ufo: Ufo, by sprite: SKSpriteNode, atPosition position: CGPoint) {
        ufo.didGetHit(by: sprite, atPosition: position)
        scoreKeeper?.addToScore(ufo.score)
        
        if let hittableSprite = sprite as? Hittable {
            hittableSprite.didGetHit(by: ufo, atPosition: position)
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
        
        if let invader = sprite as? Invader {
            invaderShieldContacts.append((invader, shield))
        }
        
        if let hittableSprite = sprite as? Hittable {
            hittableSprite.didGetHit(by: shield, atPosition: position)
        }
    }
    
    private func updateInvaderShieldContacts() {
        guard let scene = scene else {
            return
        }
        
        for contact in invaderShieldContacts {
            let contactPoint = scene.convertPoint(contact.invader.bottomRightPosition, fromNode: contact.invader)
            contact.shield.didGetHit(by: contact.invader, atPosition: contactPoint)
        }
    }
    
    // MARK: - Debug
        
    #if DEBUG_SHOW_PLAY_AREA_VIEWS
    private func addDebugViews() {
        debugShowRect(CGRect(
            x: ScreenConstants.values.ufoMinX,
            y: ScreenConstants.values.ufoY - ufo.size.height / 2,
            width: ScreenConstants.values.ufoMaxX - ScreenConstants.values.ufoMinX,
            height: ufo.size.height))
        
        debugShowRect(CGRect(
            x: ScreenConstants.values.invadersMinX,
            y: ScreenConstants.values.invadersMinY,
            width: ScreenConstants.values.invadersMaxX - ScreenConstants.values.invadersMinX,
            height: ScreenConstants.values.invadersMaxY - ScreenConstants.values.invadersMinY))
        
        debugShowRect(CGRect(
            x: ScreenConstants.values.shipMinX,
            y: ScreenConstants.values.shipY - ship.size.height / 2,
            width: ScreenConstants.values.playableWidth - 2 * ScreenConstants.values.shipMinX,
            height: ship.size.height))
    }
    #endif
}