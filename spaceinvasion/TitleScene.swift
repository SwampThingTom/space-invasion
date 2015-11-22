//
//  TitleScene.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/7/15.
//  Copyright (c) 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

class TitleScene: SKScene, GameControllersDelegate {
    
    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .AspectFit
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        addBackground()
        GameControllers.controllers().delegate = self
        
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
    
    // MARK: - GameControllerDelegate
    
    func fireButtonPressed(controller: GameControlling) {
        let gameScene = GameScene(size: self.size)
        gameScene.controller = controller
        gameScene.scaleMode = scaleMode
        let reveal = SKTransition.crossFadeWithDuration(1.5)
        view?.presentScene(gameScene, transition: reveal)
    }
    
    func menuButtonPressed(controller: GameControlling) {
        // TODO: Implement game options menu
    }
    
    func pauseButtonPressed(controller: GameControlling) {
        // do nothing
    }
}