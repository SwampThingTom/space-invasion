//
//  ShipSpriteNode.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/8/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

enum MoveDirection: CGFloat {
    case Left = -1
    case None = 0
    case Right = 1
}

class ShipSpriteNode: SKSpriteNode {
    
    private let minX: CGFloat
    private let maxX: CGFloat
    private let moveSpeed: CGFloat = 3.2 * 60
    
    var moveDirection = MoveDirection.None
    
    init(minX: CGFloat, maxX: CGFloat) {
        self.minX = minX
        self.maxX = maxX
        let texture = SKTexture(imageNamed: "Ship")
        super.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(deltaTime: CGFloat) {
        let moveDelta: CGFloat = moveDirection.rawValue * moveSpeed * deltaTime
        position.x = max(min(position.x + moveDelta, maxX), minX)
    }
}
