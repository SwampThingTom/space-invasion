//
//  GameViewController.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/7/15.
//  Copyright (c) 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit
import GameController

class GameViewController: GCEventViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = TitleScene(size: CGSize(width: 1024, height: 768))

        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        //skView.showsNodeCount = true
        //skView.showsPhysics = true
        skView.presentScene(scene)
    }
}
