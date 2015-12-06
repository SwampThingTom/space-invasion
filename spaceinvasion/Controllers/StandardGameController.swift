//
//  StandardGameController.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/21/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import GameController

/// `MicroGameController` provides `GameControlling` support for controllers that support the 
/// standard gamepad profile.

class StandardGameController : GameController {
    
    private var gamepad: GCGamepad
    
    override init(controller: GCController) {
        gamepad = controller.gamepad!
        super.init(controller: controller)
        gamepad.buttonA.pressedChangedHandler = buttonAPressed
    }
    
    // MARK: - GameControlling
    
    override var leftButtonIsPressed: Bool {
        return gamepad.dpad.left.pressed
    }
    
    override var rightButtonIsPressed: Bool {
        return gamepad.dpad.right.pressed
    }
    
    override var fireButtonIsPressed: Bool {
        return gamepad.buttonA.pressed
    }
}