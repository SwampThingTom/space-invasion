//
//  TitleScene.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/7/15.
//  Copyright (c) 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

class TitleScene: SKScene {
    
    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .AspectFit
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.purpleColor()
        
        let background = SKSpriteNode(imageNamed: "Title")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
        
        addGestureRecognizerForButton(.Select, action: "selectButtonPressed")
        addGestureRecognizerForButton(.Menu, action: "menuButtonPressed")
        
        // TODO: Start playing music
    }
    
    override func willMoveFromView(view: SKView) {
        // TODO: Stop playing music
    }
    
    func selectButtonPressed() {
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = scaleMode
        let reveal = SKTransition.crossFadeWithDuration(1.5)
        view?.presentScene(gameScene, transition: reveal)
    }
    
    func menuButtonPressed() {
        // TODO: Implement game options menu
    }
}