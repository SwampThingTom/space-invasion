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

class StandardGameController : GameControlling {
    
    private(set) var controller: GCController?
    private var gamepad: GCGamepad
    
    init(controller: GCController) {
        self.controller = controller
        gamepad = controller.gamepad!
        controller.controllerPausedHandler = pauseButtonPressed
        gamepad.buttonA.pressedChangedHandler = buttonAPressed
        gamepad.buttonX.pressedChangedHandler = buttonXPressed
    }
    
    // MARK: - GameControlling
    
    var fireButtonPressedHandler: ButtonPressedHandler?
    var menuButtonPressedHandler: ButtonPressedHandler?
    var pauseButtonPressedHandler: ButtonPressedHandler?
    
    var leftButtonIsPressed: Bool {
        return gamepad.dpad.left.pressed
    }
    
    var rightButtonIsPressed: Bool {
        return gamepad.dpad.right.pressed
    }
    
    var fireButtonIsPressed: Bool {
        return gamepad.buttonA.pressed
    }
    
    var menuButtonIsPressed: Bool {
        return gamepad.buttonX.pressed
    }
    
    private func pauseButtonPressed(controller: GCController) {
        pauseButtonPressedHandler?(self)
    }
    
    private func buttonAPressed(button: GCControllerButtonInput, value: Float, pressed: Bool) {
        if pressed {
            fireButtonPressedHandler?(self)
        }
    }
    
    private func buttonXPressed(button: GCControllerButtonInput, value: Float, pressed: Bool) {
        if pressed {
            menuButtonPressedHandler?(self)
        }
    }
}