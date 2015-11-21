//
//  TitleScene.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/7/15.
//  Copyright (c) 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

class TitleScene: SKScene, GameControllersDelegate {
    
    private var controller: GameControlling? {
        didSet {
            controller?.menuButtonPressedHandler = menuButtonPressed
            controller?.fireButtonPressedHandler = startButtonPressed
        }
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .AspectFit
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        addBackground()
        addGameController()
        
        // TODO: Start playing music
    }
    
    override func willMoveFromView(view: SKView) {
        // TODO: Stop playing music
    }
    
    private func addBackground() {
        backgroundColor = SKColor.purpleColor()
        let background = SKSpriteNode(imageNamed: "Title")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
    }
    
    private func addGameController() {
        let gameControllers = GameControllers.controllers()
        gameControllers.delegate = self
        controller = gameControllers.defaultController
    }
    
    func connectedController(controller: GameControlling) {
        if self.controller == nil {
            self.controller = controller
        }
    }
    
    func disconnectedController(controller: GameControlling) {
    }
    
    private func startButtonPressed() {
        let gameScene = GameScene(size: self.size)
        gameScene.controller = controller
        gameScene.scaleMode = scaleMode
        let reveal = SKTransition.crossFadeWithDuration(1.5)
        view?.presentScene(gameScene, transition: reveal)
    }
    
    private func menuButtonPressed() {
        // TODO: Implement game options menu
    }
}