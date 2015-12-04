//
//  HittableSprite.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/29/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

protocol Hittable {
    func didGetHit(by sprite: SKSpriteNode, atPosition position: CGPoint)
}

class HittableSprite: SKSpriteNode, Hittable {
    
    func didGetHit(by sprite: SKSpriteNode, atPosition position: CGPoint) {
        // Subclasses implement
    }
}