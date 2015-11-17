//
//  GameLabel.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/14/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

class GameLabel : SKLabelNode {
    
    init(text: String) {
        super.init(fontNamed: "Futura")
        fontColor = SKColor.whiteColor()
        self.text = text
    }
    
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
