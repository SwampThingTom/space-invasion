//
//  GameController.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/21/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import GameController

class GameController : GameControlling {
    
    private var controller: GCController
    private var gamepad: GCMicroGamepad
    
    init(controller: GCController) {
        self.controller = controller
        gamepad = controller.microGamepad!
        self.controller.controllerPausedHandler = pauseButtonPressed
        gamepad.buttonA.pressedChangedHandler = buttonAPressed
        gamepad.buttonX.pressedChangedHandler = buttonXPressed
    }
    
    // MARK: - GameControlling
    
    var fireButtonPressedHandler: ButtonPressedHandler?
    var menuButtonPressedHandler: ButtonPressedHandler?
    var playPauseButtonPressedHandler: ButtonPressedHandler?
    
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
        playPauseButtonPressedHandler?()
    }
    
    private func buttonAPressed(button: GCControllerButtonInput, value: Float, pressed: Bool) {
        if pressed {
            fireButtonPressedHandler?()
        }
    }
    
    private func buttonXPressed(button: GCControllerButtonInput, value: Float, pressed: Bool) {
        if pressed {
            menuButtonPressedHandler?()
        }
    }
}