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

    private let invaderMoveSound = [SKAction.playSoundFileNamed("inv_move_1", waitForCompletion: false),
            SKAction.playSoundFileNamed("inv_move_2", waitForCompletion: false),
            SKAction.playSoundFileNamed("inv_move_3", waitForCompletion: false),
            SKAction.playSoundFileNamed("inv_move_4", waitForCompletion: false)]
    private var moveSoundIndex = 0

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
    private var leftMostColumn = 0
    private var rightMostColumn = 0
    private var topMostRow = 0
    private var bottomMostRow = 0
    
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
        leftMostColumn = 0
        rightMostColumn = invadersPerRow - 1
        topMostRow = 0
        bottomMostRow = invaderRankForRow.count
        
        let startRow = min(level - 1, maxLevel)
        let positionOffset = descendSpeed * CGFloat(startRow * 2)
        position = CGPoint(x: minX, y: maxY) - positionOffset
        
        let spriteSize = CGPoint(x: invaderWidth + invaderXPad, y: -(invaderHeight + invaderYPad))
        invaderSprites.removeAll()
        for row in 0 ..< invaderRankForRow.count {
            for column in 0 ..< invadersPerRow {
                let invaderSprite = InvaderSpriteNode(rank: invaderRankForRow[row], row: row, column: column)
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
            invader.move(moveVector)
            if invaderDropsBomb(invader) {
                // TODO: Implement dropping bomb
                //invaderBombs.Fire(invader.Position + MissileOffset, (RandomNumber.NextDouble() < ChanceOfFastBomb))
            }
        }
        
        playInvaderMoveSound()
    }
    
    var haveInvaded: Bool {
        let bottomY = position.y - CGFloat(bottomMostRow) * (invaderHeight + invaderYPad)
        return bottomY < minY
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
    
    private func leftColumnXForPosition(position: CGPoint) -> CGFloat {
        return position.x + CGFloat(leftMostColumn) * (invaderWidth + invaderXPad)
    }
    
    private func rightColumnXForPosition(position: CGPoint) -> CGFloat {
        return position.x + CGFloat(rightMostColumn) * (invaderWidth + invaderXPad)
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
    
    private func playInvaderMoveSound() {
        runAction(invaderMoveSound[moveSoundIndex])
        moveSoundIndex++
        moveSoundIndex %= invaderMoveSound.count
    }
}
