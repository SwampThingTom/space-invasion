//
//  Invaders.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/8/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

class Invaders: SKNode {
    
    private let minX: CGFloat
    private let maxX: CGFloat
    private let minY: CGFloat
    private let maxY: CGFloat
    
    private let invaderWidth: CGFloat = 36
    private let invaderHeight: CGFloat = 24
    private let invaderXPad: CGFloat = 12
    private let invaderYPad: CGFloat = 24

    private var moveSoundIndex = 0
    private let invaderMoveSound = [
        SKAction.playSoundFileNamed("inv_move_1", waitForCompletion: true),
        SKAction.playSoundFileNamed("inv_move_2", waitForCompletion: true),
        SKAction.playSoundFileNamed("inv_move_3", waitForCompletion: true),
        SKAction.playSoundFileNamed("inv_move_4", waitForCompletion: true)]
    private let invaderHitSound = SKAction.playSoundFileNamed("inv_explode", waitForCompletion: false)

    private let invadersPerRow = 15
    private let invaderRankForRow = [
        InvaderRank.General,
        InvaderRank.Captain,
        InvaderRank.Captain,
        InvaderRank.Pawn,
        InvaderRank.Pawn]
    
    private let chanceOfDroppingBomb: CGFloat = 0.07
    private let chanceOfFastBomb: CGFloat = 0.15
    
    private let maxLevel = 7
    private var level = 1
    
    private var invaderSprites: [InvaderSpriteNode]
    private let horizontalspeed = CGPoint(x: 6, y: 0)
    private let descendSpeed = CGPoint(x: 0, y: -21)
    private var direction = MoveDirection.Right
    
    private let frameUpdateTimePerInvader: CGFloat = 1.0 / 60.0;
    private var lastFrameTime: CGFloat = 0
    private var timeSinceLastFrame: CGFloat = 0
    
    init(minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) {
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
        invaderSprites = [InvaderSpriteNode]()
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupInvasionForLevel(level: Int) {
        let startRow = min(level - 1, maxLevel)
        let positionOffset = descendSpeed * CGFloat(startRow * 2)
        position = CGPoint(x: minX, y: maxY) - positionOffset
        
        let spriteSize = CGPoint(
            x: invaderWidth + invaderXPad,
            y: -(invaderHeight + invaderYPad))
        
        invaderSprites.removeAll()
        for row in 0 ..< invaderRankForRow.count {
            for column in 0 ..< invadersPerRow {
                let invaderSprite = InvaderSpriteNode(
                    rank: invaderRankForRow[row],
                    row: row,
                    column: column)
                invaderSprite.position = CGPoint(x: column, y: row) * spriteSize
                invaderSprites.append(invaderSprite)
                addChild(invaderSprite)
            }
        }
        
        lastFrameTime = 0
        timeSinceLastFrame = 0
        moveSoundIndex = 0
    }
    
    func update(deltaTime: CGFloat) {
        if (!isNextFrameTime(deltaTime)) {
            return;
        }
        
        let moveVector = self.moveVector(deltaTime);
        position += moveVector
        
        for invader in invaderSprites {
            // TODO: It would be more efficient to set the texture for each sprite and then change the textures here
            invader.animate()
            if invaderDropsBomb(invader) {
                // TODO: Implement dropping bomb
                //invaderBombs.Fire(invader.Position + MissileOffset, (RandomNumber.NextDouble() < ChanceOfFastBomb))
            }
        }
        
        playInvaderMoveSound()
    }
    
    var haveInvaded: Bool {
        let bottomY = position.y - CGFloat(bottomRow) * (invaderHeight + invaderYPad)
        return bottomY < minY
    }
    
    var destroyed: Bool {
        return invaderSprites.count == 0
    }
    
    func invaderWasHit(invader: InvaderSpriteNode!) {
        runAction(invaderHitSound)
        invaderSprites.removeAtIndex(invaderSprites.indexOf(invader)!)
        invader.removeFromParent()
        showInvaderExplosion(invader.position)
    }
    
    func showInvaderExplosion(position: CGPoint) {
        let invaderExplosion = SKSpriteNode(imageNamed: "InvaderBoom")
        invaderExplosion.position = position
        addChild(invaderExplosion)
        invaderExplosion.runAction(SKAction.sequence([
            SKAction.waitForDuration(0.5),
            SKAction.removeFromParent()]))
    }
    
    private func isNextFrameTime(timeDelta: CGFloat) -> Bool {
        timeSinceLastFrame += timeDelta
        let nextFrameTime = lastFrameTime + frameUpdateTimePerInvader * CGFloat(invaderSprites.count)
        let currentTime = lastFrameTime + timeSinceLastFrame
        if currentTime < nextFrameTime {
            return false
        }
        
        // using nextFrameTime as the reference ensures our clock doesn't drift
        lastFrameTime = nextFrameTime
        timeSinceLastFrame = currentTime - lastFrameTime
        return true
    }
    
    private func moveVector(timeDelta: CGFloat) -> CGPoint {
        var move = horizontalspeed * direction.rawValue
        let newPosition = position + move
        if leftColumnXForPosition(newPosition) < minX || rightColumnXForPosition(newPosition) > maxX {
            move = descendSpeed
            direction = direction.reverse()
        }
        return move
    }
    
    private func invaderDropsBomb(invader: InvaderSpriteNode) -> Bool {
        if !invaderAtBottom(invader) {
            return false
        }
        return random() <= chanceOfDroppingBomb
    }
    
    private func invaderAtBottom(invader: InvaderSpriteNode) -> Bool {
        let bottomRow = invaderSprites
            .filter { $0.column == invader.column }
            .reduce(0) { (maxRow, sprite) in max(maxRow, sprite.row) }
        return invader.row == bottomRow
    }
    
    private var leftColumn: Int {
        return invaderSprites.reduce(invadersPerRow, combine: {
            (minColumn, sprite) in min(minColumn, sprite.column)
        })
        
    }
    
    private var rightColumn: Int {
        return invaderSprites.reduce(0, combine: {
            (maxColumn, sprite) in max(maxColumn, sprite.column)
        })
    }
    
    private var topRow: Int {
        return invaderSprites.reduce(invaderRankForRow.count, combine: {
            (minRow, sprite) in min(minRow, sprite.row)
        })
    }
    
    private var bottomRow: Int {
        return invaderSprites.reduce(0, combine: {
            (maxRow, sprite) in max(maxRow, sprite.row)
        })
    }
    
    private func leftColumnXForPosition(position: CGPoint) -> CGFloat {
        return position.x + CGFloat(leftColumn) * (invaderWidth + invaderXPad)
    }
    
    private func rightColumnXForPosition(position: CGPoint) -> CGFloat {
        return position.x + CGFloat(rightColumn) * (invaderWidth + invaderXPad)
    }
    
    private func playInvaderMoveSound() {
        runAction(invaderMoveSound[moveSoundIndex])
        moveSoundIndex++
        moveSoundIndex %= invaderMoveSound.count
    }
}
