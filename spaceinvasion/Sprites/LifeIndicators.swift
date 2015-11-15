//
//  LifeIndicators.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/14/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

class LifeIndicators : SKNode {
    
    private var lifeIndicators = [SKSpriteNode]()
    
    // Note that we display 1 less icon than the number of lives the player has remaining.
    // So if the player has 3 lives (at the start of game), we show 2 icons.
    init(maxLives: Int) {
        super.init()
        var xOffset: CGFloat = 0
        for _ in 0 ..< maxLives-1 {
            let lifeIndicator = SKSpriteNode(imageNamed: "Ship")
            lifeIndicator.position = CGPoint(x: xOffset, y: 0)
            lifeIndicators.append(lifeIndicator)
            xOffset += lifeIndicator.frame.width * 1.2
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showLives(numLives: Int) {
        assert(numLives >= 0 && numLives < lifeIndicators.count)
        removeAllChildren()
        for i in 0 ..< numLives-1 {
            addChild(lifeIndicators[i])
        }
    }
}
