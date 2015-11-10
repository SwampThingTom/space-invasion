//
//  Random.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/8/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import CoreGraphics

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / Float(UInt32.max))
}
