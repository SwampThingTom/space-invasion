//
//  Invader.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/8/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

enum InvaderRank {
    case Pawn, Captain, General

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

class Invader: SKSpriteNode {

    let rank: InvaderRank
    let row: Int
    let column: Int

    private let textures: [SKTexture]
    private var textureIndex = 0
    
    var score: Int {
        return rank.scoreValue()
    }
    
    init(rank: InvaderRank, row: Int, column: Int) {
        self.rank = rank
        self.row = row
        self.column = column
        textures = InvaderTextures.texturesForRank(rank)
        super.init(texture: textures[0], color: SKColor.whiteColor(), size: textures[0].size())
        self.physicsBody = SKPhysicsBody(rectangleOfSize: texture!.size())
        self.physicsBody?.dynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Invader.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategory.None.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.ShipMissile.rawValue
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func animate() {
        textureIndex = (textureIndex + 1) % 2
        texture = textures[textureIndex]
    }

    private struct InvaderTextures {
        static func texturesForRank(rank: InvaderRank) -> [SKTexture] {
            switch rank {
            case .Pawn:
                return pawnTextures
            case .Captain:
                return captainTextures
            case .General:
                return generalTextures
            }
        }

        private static let pawnTextures = [SKTexture(imageNamed: "Invader_1_1"), SKTexture(imageNamed: "Invader_1_2")]
        private static let captainTextures = [SKTexture(imageNamed: "Invader_2_1"), SKTexture(imageNamed: "Invader_2_2")]
        private static let generalTextures = [SKTexture(imageNamed: "Invader_3_1"), SKTexture(imageNamed: "Invader_3_2")]
    }
}
