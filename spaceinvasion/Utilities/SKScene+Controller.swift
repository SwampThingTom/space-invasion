//
//  SKScene+Controller.swift
//  SpaceInvasion
//
//  Created by Thomas Aylesworth on 11/15/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit

extension SKScene {
    
    func addGestureRecognizerForButton(button: UIPressType, action: Selector) {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: action)
        gestureRecognizer.allowedPressTypes = [NSNumber(integer: button.rawValue)]
        view?.addGestureRecognizer(gestureRecognizer)
    }
}