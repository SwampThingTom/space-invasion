//
//  GameScene.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/8/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

protocol GameControlListening {
    
    func moveLeft()
    func moveRight()
    func stopMoving()
    func fire()
}

class GameScene: SKScene, ScoreKeeping {
    
    // TODO: Consider creating these in init so we don't have to deal with optionals
    private var scoreTextLabel: GameLabel?
    private var scoreLabel: GameLabel?
    private var highScoreTextLabel: GameLabel?
    private var highScoreLabel: GameLabel?
    private var playArea: PlayArea?
    private var pausedOverlay: SKSpriteNode?
    
    private var controlListener: GameControlListening?
    
    private var score = 0
    private var lives = 3
    
    private var lastUpdateTime: CFTimeInterval = 0
    private var gamePaused = false
    
    private var limboEndTime: CFTimeInterval = 0
    private var inLimbo = false
    
    // MARK: - View lifecycle
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        addPlayArea()
        addLabels()
        addPhysics()
        addControlsToView()
        createOverlays()
        
        // TODO: Add life indicators
    }
    
    private func addPlayArea() {
        playArea = PlayArea()
        let x = (size.width - ScreenConstants.values.playableWidth) / 2
        let y = (size.height - ScreenConstants.values.playableHeight) / 2
        playArea?.position = CGPoint(x: x, y: y)
        playArea?.scoreKeeper = self
        controlListener = playArea
        addChild(playArea!)
    }
    
    private func addLabels() {
        scoreTextLabel = GameLabel(text: "Score")
        scoreTextLabel?.horizontalAlignmentMode = .Left
        let textLabelX = ScreenConstants.values.invadersMinX
        let textLine1Y = size.height - scoreTextLabel!.frame.height
        scoreTextLabel?.position = CGPoint(x: textLabelX, y: textLine1Y)
        addChild(scoreTextLabel!)
        
        scoreLabel = GameLabel(text: "0000")
        let scoreLabelX = scoreTextLabel!.frame.minX + scoreTextLabel!.frame.width / 2
        let textLine2Y = textLine1Y - scoreTextLabel!.frame.height * 1.5
        scoreLabel?.position = CGPoint(x: scoreLabelX, y: textLine2Y)
        addChild(scoreLabel!)
        
        highScoreTextLabel = GameLabel(text: "High Score")
        let highScoreLabelX = size.width / 2
        highScoreTextLabel?.position = CGPoint(x: highScoreLabelX, y: textLine1Y)
        addChild(highScoreTextLabel!)
        
        highScoreLabel = GameLabel(text: "0000")
        highScoreLabel?.position = CGPoint(x: highScoreLabelX, y: textLine2Y)
        addChild(highScoreLabel!)
    }
    
    private func addPhysics() {
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = playArea!
    }
    
    private func addControlsToView() {
        addGestureRecognizerForButton(.Select, action: "fireButtonPressed")
        addGestureRecognizerForButton(.Menu, action: "menuButtonPressed")
        addGestureRecognizerForButton(.PlayPause, action: "pauseButtonPressed")
    }
    
    private func createOverlays() {
        let pausedOverlayTexture = SKTexture(imageNamed: "GamePaused")
        pausedOverlay = SKSpriteNode(texture: pausedOverlayTexture)
        pausedOverlay?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        pausedOverlay?.zPosition = 10
    }
    
    // MARK: - Input handling
    
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
            controlListener?.moveLeft()
        }
        else if touchLocation.x > touchStartLocation.x + touchEpsilon {
            controlListener?.moveRight()
        }
        else {
            controlListener?.stopMoving()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        controlListener?.stopMoving()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        controlListener?.stopMoving()
    }
    
    func fireButtonPressed() {
        controlListener?.fire()
    }
    
    func menuButtonPressed() {
        // TODO: Prompt user before immediately going back
        returnToMainMenu()
    }
    
    func pauseButtonPressed() {
        gamePaused = !gamePaused
        if gamePaused {
            addChild(pausedOverlay!)
        }
        else {
            lastUpdateTime = 0
            pausedOverlay!.removeFromParent()
        }
    }
    
    // MARK: - Game loop
    
    override func update(currentTime: CFTimeInterval) {
        if gamePaused {
            return
        }
        
        if inLimbo && currentTime < limboEndTime {
            if currentTime < limboEndTime {
                return
            }
            exitLimbo()
        }
        
        var deltaTime: CGFloat = CGFloat(currentTime - lastUpdateTime)
        if deltaTime > 0.5 {
            deltaTime = 1 / 60
        }
        lastUpdateTime = currentTime
        playArea!.update(deltaTime)
    }
    
    override func didFinishUpdate() {
        if playArea!.invaded {
            gameOver()
        }
    }
    
    func gameOver() {
        // TODO: Show "Game Over" overlay
        returnToMainMenu()
    }
    
    // MARK: - Score keeping
    
    func addToScore(score: Int) {
        self.score += score
        scoreLabel?.text = String(format: "%04d", self.score)
    }
    
    func invadersDestroyed() {
        // TODO: Probably need some sort of pause in here ...
        playArea?.setupNextInvasionLevel()
    }
    
    func shipDestroyed() {
        if (--lives == 0) {
            gameOver()
            return
        }
        
        // TODO: Update life indicators
        
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