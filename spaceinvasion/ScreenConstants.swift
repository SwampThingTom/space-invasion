//
//  ScreenConstants.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/15/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

struct ScreenConstants {
    
    let backgroundImageName = "Background"
    
    let playableWidth: CGFloat = 744
    let playableHeight: CGFloat = 768
    
    let ufoMinX: CGFloat = 0
    let ufoMaxX: CGFloat
    let ufoY: CGFloat
    
    let invadersPerRow: Int = 11
    let invadersMinX: CGFloat
    let invadersMaxX: CGFloat
    let invadersMinY: CGFloat = 148
    let invadersMaxY: CGFloat
    
    let numShields: Int = 4
    let shieldWidth: CGFloat = 68
    let shieldY: CGFloat
    
    let shipMinX: CGFloat
    let shipMaxX: CGFloat
    let shipY: CGFloat
    
    let livesIndicatorY: CGFloat
    let shipMissileMaxY: CGFloat = 705
    
    let overlayZPosition: CGFloat = 100
    let ufoZPosition: CGFloat = 10
    let invaderZPosition: CGFloat = 10
    let shipZPosition: CGFloat = 10
    let missileZPosition: CGFloat = 10
    let shieldZPosition: CGFloat = 0
    let backgroundZPosition: CGFloat = -100
    
    static var values = ScreenConstants()
    
    // TODO: Read from plist
    private init() {
        ufoMaxX = playableWidth
        ufoY = shipMissileMaxY - 32
        
        let invadersXMargin: CGFloat = 72
        let invadersHeight: CGFloat = 432
        invadersMinX = invadersXMargin
        invadersMaxX = playableWidth - invadersXMargin
        invadersMaxY = invadersMinY + invadersHeight
        
        let shipMargin: CGFloat = 90
        shipMinX = shipMargin
        shipMaxX = playableWidth - shipMargin
        shipY = invadersMinY - 28
        shieldY = shipY + 72
        livesIndicatorY = shipY - 60
    }
}