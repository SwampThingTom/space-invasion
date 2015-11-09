//
//  InvaderSpriteNode.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/8/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

enum InvaderRank {
    case Pawn, Captain, General
    
    func imageName() -> String {
        switch self {
        case Pawn:
            return "Invader_1_1"
        case Captain:
            return "Invader_2_1"
        case General:
            return "Invader_3_1"
        }
    }
    
    func scoreValue() -> Int {
        switch self {
        case Pawn:
            return 10
        case Captain:
            return 20
        case General:
            return 30
        }
    }
}

class InvaderSpriteNode: SKSpriteNode {

    let rank: InvaderRank
    let row: Int
    let column: Int
    
    var score: Int {
        return rank.scoreValue()
    }
    
    init(rank: InvaderRank, row: Int, column: Int) {
        self.rank = rank
        self.row = row
        self.column = column
        let texture = SKTexture(imageNamed: rank.imageName())
        super.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(moveVector: CGPoint) {
        position += moveVector
        // TODO: Update animation frame
    }
}
