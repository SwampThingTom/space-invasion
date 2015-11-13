//
//  GameScene.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/8/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // TODO: Move to a plist file
    let backgroundImageName = "Background"
    let shipHorizontalMargin: CGFloat = 108
    let shipY: CGFloat = 100
    let playableAreaMaxY: CGFloat = 705
    let invadersHorizontalMargin: CGFloat = 72
    let invadersMinY: CGFloat = 135
    let invadersMaxY: CGFloat = 605
    
    var ship: ShipSpriteNode?
    var shipMissile: ShipMissileSpriteNode?
    var invaders: Invaders?
    
    var level = 1
    var lastUpdateTime: CGFloat = 0
    
    // MARK: View lifecycle
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        let background = SKSpriteNode(imageNamed: backgroundImageName)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
        
        ship = ShipSpriteNode(minX: shipHorizontalMargin, maxX: background.size.width - shipHorizontalMargin)
        ship!.position = CGPoint(x: shipHorizontalMargin, y: shipY)
        addChild(ship!)
        
        shipMissile = ShipMissileSpriteNode(maxY: playableAreaMaxY)
        
        invaders = Invaders(
            minX: invadersHorizontalMargin,
            maxX: background.size.width - invadersHorizontalMargin,
            minY: invadersMinY,
            maxY: invadersMaxY)
        invaders!.setupInvasionForLevel(level)
        addChild(invaders!)
        
        let fireButtonGestureRecognizer = UITapGestureRecognizer(target: self, action: "fireButtonPressed")
        fireButtonGestureRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
        view.addGestureRecognizer(fireButtonGestureRecognizer)
        
        if Settings.debug {
            debugAddRect(CGRect(
                x: invadersHorizontalMargin,
                y: invadersMinY,
                width: background.size.width - 2 * invadersHorizontalMargin,
                height: invadersMaxY - invadersMinY))
            
            debugAddRect(CGRect(
                x: shipHorizontalMargin,
                y: shipY - ship!.size.height / 2,
                width: background.size.width - 2 * shipHorizontalMargin,
                height: ship!.size.height))
        }
        
        // TODO: Start playing music
    }
    
    override func willMoveFromView(view: SKView) {
        // TODO: Stop playing music
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
        guard let shipMissile = shipMissile as ShipMissileSpriteNode! else {
            return
        }
        
        if shipMissile.active {
            return
        }
        
        shipMissile.fire(ship!.position)
        addChild(shipMissile)
    }
    
    // MARK: Game loop
    
    override func update(currentTime: CFTimeInterval) {
        let deltaTime: CGFloat = lastUpdateTime > 0 ? CGFloat(currentTime) - lastUpdateTime : 0.0
        lastUpdateTime = CGFloat(currentTime)
        ship?.update(deltaTime)
        shipMissile?.update(deltaTime)
        invaders?.update(deltaTime)
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
