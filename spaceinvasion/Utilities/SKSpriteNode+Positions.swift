//
//  SKSpriteNode+Positions.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 12/6/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

extension SKSpriteNode {
    var bottomLeftPosition: CGPoint {
        return CGPoint(x: -size.width, y: -size.height) * anchorPoint
    }
    var bottomRightPosition: CGPoint {
        return CGPoint(x: size.width, y: -size.height) * anchorPoint
    }
    var topLeftPosition: CGPoint {
        return CGPoint(x: -size.width, y: size.height) * anchorPoint
    }
    var topRightPosition: CGPoint {
        return CGPoint(x: size.width, y: size.height) * anchorPoint
    }
}