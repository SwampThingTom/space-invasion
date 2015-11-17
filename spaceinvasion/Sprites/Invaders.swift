//
//  Invaders.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/8/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

class Invaders: SKNode {
    
    private let invaderSize = CGSize(width: 36, height: 24)
    private let invaderPaddingSize = CGSize(width: 12, height: 24)
    
    // The size of an invader plus the padding between invaders
    private let invaderCellSize: CGSize

    private var moveSoundIndex = 0
    private let invaderMoveSound = [
        SKAction.playSoundFileNamed("inv_move_1", waitForCompletion: true),
        SKAction.playSoundFileNamed("inv_move_2", waitForCompletion: true),
        SKAction.playSoundFileNamed("inv_move_3", waitForCompletion: true),
        SKAction.playSoundFileNamed("inv_move_4", waitForCompletion: true)]
    private let invaderHitSound = SKAction.playSoundFileNamed("inv_explode", waitForCompletion: false)

    private let invaderRankForRow = [
        InvaderRank.General,
        InvaderRank.Captain,
        InvaderRank.Captain,
        InvaderRank.Pawn,
        InvaderRank.Pawn]
    
    private let chanceOfDroppingBomb: CGFloat = 0.07
    private let chanceOfFastBomb: CGFloat = 0.15
    
    private let maxLevel = 7
    private var level = 0
    
    private var invaderSprites: [Invader]
    private var invaderBombs: [InvaderBomb]
    private let horizontalspeed = CGPoint(x: 8, y: 0)
    private let descendSpeed = CGPoint(x: 0, y: -24)
    private var direction = MoveDirection.Right
    
    private let frameUpdateTimePerInvader: CGFloat = 0.5 / 60.0;
    private var lastFrameTime: CGFloat = 0
    private var timeSinceLastFrame: CGFloat = 0
    
    override init() {
        invaderCellSize = invaderSize + invaderPaddingSize
        invaderSprites = [Invader]()
        invaderBombs = [InvaderBomb]()
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupNextInvasionLevel() {
        level++
        setupInvasionForLevel(level)
    }
    
    private func setupInvasionForLevel(level: Int) {
        let startRow = min(level - 1, maxLevel)
        let rowOffset = descendSpeed * CGFloat(startRow * -2)
        let rowWidth = invaderCellSize.width * CGFloat(ScreenConstants.values.invadersPerRow - 1)
        let areaWidth = ScreenConstants.values.invadersMaxX - ScreenConstants.values.invadersMinX
        let x = ScreenConstants.values.invadersMinX + (areaWidth - rowWidth) / 2
        let y = ScreenConstants.values.invadersMaxY
        position = CGPoint(x: x, y: y) - rowOffset
        
        invaderBombs.removeAll()
        invaderSprites.removeAll()
        for row in 0 ..< invaderRankForRow.count {
            for column in 0 ..< ScreenConstants.values.invadersPerRow {
                let invaderSprite = Invader(
                    rank: invaderRankForRow[row],
                    row: row,
                    column: column)
                invaderSprite.position = CGPoint(x: column, y: -row) * invaderCellSize
                invaderSprites.append(invaderSprite)
                addChild(invaderSprite)
            }
        }
        
        lastFrameTime = 0
        timeSinceLastFrame = 0
        moveSoundIndex = 0
    }
    
    func update(deltaTime: CGFloat) {
        updateBombs(deltaTime)
        updateInvaders(deltaTime)
    }
    
    var haveInvaded: Bool {
        let bottomY = position.y - CGFloat(bottomRow) * invaderCellSize.height
        return bottomY < ScreenConstants.values.invadersMinY
    }
    
    var destroyed: Bool {
        return invaderSprites.count == 0
    }
    
    func invaderWasHit(invader: Invader!) {
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
    
    private func updateBombs(deltaTime: CGFloat) {
        // Remove inactive bombs before updating bomb positions.
        invaderBombs = invaderBombs.filter { $0.parent != nil }
        for bomb in invaderBombs {
            bomb.update(deltaTime)
        }
    }
    
    private func updateInvaders(deltaTime: CGFloat) {
        // Invaders move together at specific times, getting faster as there are fewer of them.
        if (!isNextMoveTime(deltaTime)) {
            return
        }
        
        position += self.moveVector()
        
        for invader in invaderSprites {
            // TODO: It would be more efficient to set the texture for each sprite and then change the textures here
            invader.animate()
            if invaderDropsBomb(invader) {
                dropBomb(invader)
            }
        }
        
        playInvaderMoveSound()
    }
    
    private func isNextMoveTime(timeDelta: CGFloat) -> Bool {
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
    
    private func moveVector() -> CGPoint {
        let minX = ScreenConstants.values.invadersMinX
        let maxX = ScreenConstants.values.invadersMaxX
        
        var move = horizontalspeed * direction.rawValue
        let newPosition = position + move
        
        if leftColumnXForPosition(newPosition) < minX || rightColumnXForPosition(newPosition) > maxX {
            move = descendSpeed
            direction = direction.reverse()
        }
        
        return move
    }
    
    private func invaderDropsBomb(invader: Invader) -> Bool {
        if !invaderAtBottom(invader) {
            return false
        }
        return random() <= chanceOfDroppingBomb
    }
    
    private func dropBomb(invader: Invader) {
        let bombType: InvaderBombType = random() < chanceOfFastBomb ? .Fast : .Slow
        let bomb = InvaderBomb(type: bombType)
        bomb.position = position + invader.position - CGPoint(x: 0, y: invaderSize.height)
        invaderBombs.append(bomb)
        
        // Adding to parent so that it moves independently of the Invaders
        parent?.addChild(bomb)
    }
    
    private func invaderAtBottom(invader: Invader) -> Bool {
        let bottomRow = invaderSprites
            .filter { $0.column == invader.column }
            .reduce(0) { (maxRow, sprite) in max(maxRow, sprite.row) }
        return invader.row == bottomRow
    }
    
    private var leftColumn: Int {
        return invaderSprites.reduce(ScreenConstants.values.invadersPerRow, combine: {
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
        return position.x + CGFloat(leftColumn) * invaderCellSize.width
    }
    
    private func rightColumnXForPosition(position: CGPoint) -> CGFloat {
        return position.x + CGFloat(rightColumn) * invaderCellSize.width
    }
    
    private func playInvaderMoveSound() {
        runAction(invaderMoveSound[moveSoundIndex])
        moveSoundIndex++
        moveSoundIndex %= invaderMoveSound.count
    }
}