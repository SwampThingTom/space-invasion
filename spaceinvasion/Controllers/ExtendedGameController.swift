//
//  ExtendedGameController.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/22/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import GameController

/// `ExtendedGameController` provides `GameControlling` support for controllers that support the
/// extended gamepad profile.

class ExtendedGameController : GameController {
    
    private var gamepad: GCExtendedGamepad
    
    override init(controller: GCController) {
        gamepad = controller.extendedGamepad!
        super.init(controller: controller)
        gamepad.buttonA.pressedChangedHandler = buttonAPressed
    }
    
    // MARK: - GameControlling
    
    override var leftButtonIsPressed: Bool {
        return gamepad.leftThumbstick.left.pressed || gamepad.dpad.left.pressed
    }
    
    override var rightButtonIsPressed: Bool {
        return gamepad.leftThumbstick.right.pressed || gamepad.dpad.right.pressed
    }
    
    override var fireButtonIsPressed: Bool {
        return gamepad.buttonA.pressed
    }
}