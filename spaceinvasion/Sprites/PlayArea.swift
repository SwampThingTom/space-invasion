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
    case ShipMissile = 0x02
    case Invader = 0x04
    case InvaderMissile = 0x08
}

protocol ScoreKeeping {
    func addToScore(score: Int)
    func shipDestroyed()
    func invadersDestroyed()
}

class PlayArea : SKNode, SKPhysicsContactDelegate, GameControlListening {
    
    var scoreKeeper: ScoreKeeping?
    
    var invaded: Bool {
        return invaders!.haveInvaded
    }
    
    // TODO: Consider creating these in init so we don't have to deal with optionals
    private var background: SKSpriteNode?
    private var ship: Ship?
    private var shipMissile: ShipMissile?
    private var invaders: Invaders?
    
    override init() {
        super.init()
        addBackground()
        addShip()
        addInvaders()
        
        if Settings.debug {
            addDebugViews()
        }
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
    
    private func addDebugViews() {
        debugAddRect(CGRect(
            x: ScreenConstants.values.invadersMinX,
            y: ScreenConstants.values.invadersMinY,
            width: ScreenConstants.values.invadersMaxX - ScreenConstants.values.invadersMinX,
            height: ScreenConstants.values.invadersMaxY - ScreenConstants.values.invadersMinY))
        
        debugAddRect(CGRect(
            x: ScreenConstants.values.shipMinX,
            y: ScreenConstants.values.shipY - ship!.size.height / 2,
            width: ScreenConstants.values.playableWidth - 2 * ScreenConstants.values.shipMinX,
            height: ship!.size.height))
    }
    
    // MARK: - Level setup
    
    func setupNextInvasionLevel() {
        invaders!.setupNextInvasionLevel()
    }
    
    // MARK: - Game loop
    
    func update(deltaTime: CGFloat) {
        ship?.update(deltaTime)
        shipMissile?.update(deltaTime)
        invaders?.update(deltaTime)
    }
    
    // MARK: - Game control listening
    
    func moveLeft() {
        ship?.moveDirection = .Left
    }
    
    func moveRight() {
        ship?.moveDirection = .Right
    }
    
    func stopMoving() {
        ship?.moveDirection = .None
    }
    
    func fire() {
        if shipMissile!.active {
            return
        }
        
        shipMissile!.fire(ship!.position)
        addChild(shipMissile!)
    }
    
    // MARK: - Physics contact delegate
    
    func didBeginContact(contact: SKPhysicsContact) {
        if let invader = contact.bodyA.node as? Invader {
            guard let missile = contact.bodyB.node as! ShipMissile! else {
                return
            }
            invaderWasHit(invader, byMissile: missile)
        }
        else if let ship = contact.bodyA.node as? Ship {
            guard let bomb = contact.bodyB.node as! InvaderBomb! else {
                return
            }
            shipWasHit(ship, byBomb: bomb)
        }
    }
    
    private func invaderWasHit(invader: Invader!, byMissile missile: ShipMissile!) {
        invaders!.invaderWasHit(invader)
        missile.remove()
        scoreKeeper?.addToScore(invader.score)
        
        if invaders!.destroyed {
            scoreKeeper?.invadersDestroyed()
        }
    }
    
    private func shipWasHit(ship: Ship!, byBomb bomb: InvaderBomb!) {
        // TODO: Show ship explosion, make noise, enter limbo
        bomb.removeFromParent()
        scoreKeeper?.shipDestroyed()
    }
    
    // MARK: - Debug
    
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
