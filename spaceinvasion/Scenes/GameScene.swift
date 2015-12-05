//
//  GameScene.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/8/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, ScoreKeeping {
    
    private let controller: GameControlling
    private let scoreLabel = GameLabel(text: "0000")
    private let highScoreLabel = GameLabel(text: "0000")
    private let livesIndicator = LifeIndicators(maxLives: 3)
    private let playArea = PlayArea()
    private let pausedOverlay: SKNode
    private let gameOverOverlay: SKNode
    
    private var highScore: Int = NSUserDefaults.standardUserDefaults().integerForKey("HighScore") {
        didSet {
            NSUserDefaults.standardUserDefaults().setInteger(highScore, forKey: "HighScore")
        }
    }
    
    private var score = 0
    private var lives = 3 {
        didSet {
            livesIndicator.showLives(lives)
        }
    }
    
    private var lastUpdateTime: CFTimeInterval = 0
    private var gamePaused = false
    private var gameOver = false
    
    private var limboEndTime: CFTimeInterval = 0
    private var inLimbo = false
    
    init(size: CGSize, controller: GameControlling) {
        self.controller = controller
        
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        pausedOverlay = GameScene.overlayWithImageNamed(imageNamed: "GamePaused", position: center)
        gameOverOverlay = GameScene.overlayWithImageNamed(imageNamed: "GameOver", position: center)
        
        super.init(size: size)
        backgroundColor = SKColor.blackColor()
        self.controller.menuButtonPressedHandler = menuButtonPressed
        self.controller.pauseButtonPressedHandler = pauseButtonPressed
        initializeHighScore()
        
        addPlayArea()
        addLabels()
        addLivesIndicator()
        addPhysics()
        preloadTextures()
    }
    
    private override init(size: CGSize) {
        fatalError("use init(size:controller:) instead")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeHighScore() {
        highScoreLabel.text = String(format: "%04d", self.highScore)
    }
    
    private func addPlayArea() {
        let x = (size.width - ScreenConstants.values.playableWidth) / 2
        let y = (size.height - ScreenConstants.values.playableHeight) / 2
        playArea.position = CGPoint(x: x, y: y)
        playArea.controller = controller
        playArea.scoreKeeper = self
        addChild(playArea)
    }
    
    private func addLabels() {
        let scoreTextLabel = GameLabel(text: "Score")
        scoreTextLabel.horizontalAlignmentMode = .Left
        let textLabelX = ScreenConstants.values.invadersMinX
        let textLine1Y = size.height - scoreTextLabel.frame.height
        scoreTextLabel.position = CGPoint(x: textLabelX, y: textLine1Y)
        addChild(scoreTextLabel)
        
        let scoreLabelX = scoreTextLabel.frame.minX + scoreTextLabel.frame.width / 2
        let textLine2Y = textLine1Y - scoreTextLabel.frame.height * 1.5
        scoreLabel.position = CGPoint(x: scoreLabelX, y: textLine2Y)
        addChild(scoreLabel)
        
        let highScoreTextLabel = GameLabel(text: "High Score")
        let highScoreLabelX = size.width / 2
        highScoreTextLabel.position = CGPoint(x: highScoreLabelX, y: textLine1Y)
        addChild(highScoreTextLabel)
        
        highScoreLabel.position = CGPoint(x: highScoreLabelX, y: textLine2Y)
        addChild(highScoreLabel)
    }
    
    private func addLivesIndicator() {
        livesIndicator.position = CGPoint(
            x: ScreenConstants.values.invadersMinX,
            y: ScreenConstants.values.livesIndicatorY)
        addChild(livesIndicator)
        livesIndicator.showLives(lives)
    }
    
    private func addPhysics() {
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = playArea
    }
    
    private func preloadTextures() {
        gamePaused = true
        let textures = [
            SKTexture(imageNamed: "Bomb_1"),
            SKTexture(imageNamed: "Bomb_2"),
            SKTexture(imageNamed: "Invader_1_1"),
            SKTexture(imageNamed: "Invader_1_2"),
            SKTexture(imageNamed: "Invader_2_1"),
            SKTexture(imageNamed: "Invader_2_2"),
            SKTexture(imageNamed: "Invader_3_1"),
            SKTexture(imageNamed: "Invader_3_2"),
            SKTexture(imageNamed: "InvaderBoom"),
            SKTexture(imageNamed: "Missile"),
            SKTexture(imageNamed: "Shield"),
            SKTexture(imageNamed: "ShieldBombMask"),
            SKTexture(imageNamed: "ShieldMissileMask"),
            SKTexture(imageNamed: "Ship"),
            SKTexture(imageNamed: "ShipBoom")]
        
        SKTexture.preloadTextures(textures) {
            self.startGame()
        }
    }
    
    private func startGame() {
        playArea.startGame()
        self.gamePaused = false
    }
    
    private class func overlayWithImageNamed(imageNamed imageName: String, position: CGPoint) -> SKNode {
        let texture = SKTexture(imageNamed: imageName)
        let overlay = SKSpriteNode(texture: texture)
        overlay.position = position
        overlay.zPosition = 1000
        return overlay
    }
    
    // MARK: - Game controls
    
    func menuButtonPressed(controller: GameControlling) {
        // TODO: Prompt user before immediately going back
        returnToMainMenu()
    }
    
    func pauseButtonPressed(controller: GameControlling) {
        gamePaused = !gamePaused
        if gamePaused {
            addChild(pausedOverlay)
        }
        else {
            lastUpdateTime = 0
            pausedOverlay.removeFromParent()
        }
    }
    
    // MARK: - Game loop
    
    override func update(currentTime: CFTimeInterval) {
        if gamePaused || gameOver {
            return
        }
        
        if inLimbo && currentTime < limboEndTime {
            exitLimbo()
        }
        
        var deltaTime: CGFloat = CGFloat(currentTime - lastUpdateTime)
        if deltaTime > 0.5 {
            deltaTime = 1 / 60
        }
        lastUpdateTime = currentTime
        playArea.update(deltaTime)
    }
    
    override func didFinishUpdate() {
        if playArea.invaded {
            gameIsOver()
        }
    }
    
    private func gameIsOver() {
        gameOver = true
        addChild(gameOverOverlay)
        runAction(SKAction.sequence([
            SKAction.waitForDuration(2),
            SKAction.runBlock() {
                self.returnToMainMenu()
            }]))
    }
    
    // MARK: - Score keeping
    
    func addToScore(score: Int) {
        self.score += score
        scoreLabel.text = String(format: "%04d", self.score)
        if self.score > highScore {
            highScore = self.score
            highScoreLabel.text = scoreLabel.text
        }
    }
    
    func invadersDestroyed() {
        // TODO: Probably need some sort of pause in here ...
        playArea.setupNextInvasionLevel()
    }
    
    func shipDestroyed() {
        if (--lives == 0) {
            gameIsOver()
            return
        }
        enterLimbo()
    }
    
    // MARK: - Limbo
    
    private func enterLimbo() {
        inLimbo = true
        limboEndTime = lastUpdateTime + 2
    }
    
    private func exitLimbo() {
        inLimbo = false
    }
    
    // MARK: - Scene transitions
    
    private func returnToMainMenu() {
        let titleScene = TitleScene(size: self.size)
        let reveal = SKTransition.crossFadeWithDuration(1.5)
        view?.presentScene(titleScene, transition: reveal)
    }
}