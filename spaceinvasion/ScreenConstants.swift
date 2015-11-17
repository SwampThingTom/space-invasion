//
//  ScreenConstants.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/15/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

struct ScreenConstants {
    
    let backgroundImageName: String
    
    let playableWidth: CGFloat
    let playableHeight: CGFloat
    
    let invadersMinX: CGFloat
    let invadersMaxX: CGFloat
    let invadersMinY: CGFloat
    let invadersMaxY: CGFloat
    let invadersPerRow: Int
    
    let shipMinX: CGFloat
    let shipMaxX: CGFloat
    let shipY: CGFloat
    
    let shipMissileMaxY: CGFloat
        
    private static let isRetro = true
    static var values = ScreenConstants()
    
    private init() {
        // TODO: Read from plist
        if (!ScreenConstants.isRetro) {
            backgroundImageName = "Background"
            
            playableWidth = 976
            playableHeight = 768
            
            let invadersMargin: CGFloat = 72
            let invadersHeight: CGFloat = 432
            invadersMinX = invadersMargin
            invadersMaxX = playableWidth - invadersMargin
            invadersMinY = 138
            invadersMaxY = invadersMinY + invadersHeight
            invadersPerRow = 15
            
            let shipMargin: CGFloat = 90
            shipMinX = shipMargin
            shipMaxX = playableWidth - shipMargin
            shipY = 110
            
            shipMissileMaxY = 705
        }
        else {
            backgroundImageName = "Background"
            
            playableWidth = 744
            playableHeight = 768
            
            let invadersXMargin: CGFloat = 72
            let invadersHeight: CGFloat = 432
            invadersMinX = invadersXMargin
            invadersMaxX = playableWidth - invadersXMargin
            invadersMinY = 148
            invadersMaxY = invadersMinY + invadersHeight
            invadersPerRow = 11
            
            let shipMargin: CGFloat = 90
            shipMinX = shipMargin
            shipMaxX = playableWidth - shipMargin
            shipY = invadersMinY - 28
            
            shipMissileMaxY = 705
        }
    }
}