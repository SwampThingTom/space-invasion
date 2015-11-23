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
        
        if Settings.debug {
            debugShowFonts()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        addBackground()
        addTitle()
        startMusic()
        GameControllers.controllers().delegate = self
    }
    
    private func addBackground() {
        backgroundColor = SKColor.purpleColor()
        let background = SKSpriteNode(imageNamed: "Title")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
    }
    
    private func addTitle() {
        let title = SKLabelNode()
        title.position = CGPoint(x: size.width/2, y: 2*size.height/3)
        title.text = "Space Invasion"
        
        // TODO: This font is not displaying on an actual Apple TV device (works fine in simulator)
        title.fontName = "ViperSquadronItalic"
        title.fontSize = 96
        title.fontColor = UIColor(red: 0.7098, green: 0.7098, blue: 0.8667, alpha: 1.0)
        addChild(title)
    }
    
    private func startMusic() {
        let music = SKAudioNode(fileNamed: "music")
        addChild(music)
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
    
    private func debugShowFonts() {
        for fontFamily in UIFont.familyNames() {
            let fontNames = UIFont.fontNamesForFamilyName(fontFamily)
            print("\(fontFamily): \(fontNames)")
        }
    }
}