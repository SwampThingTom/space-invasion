//
//  GameController.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/22/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import GameController

/// The `GameController` class is the parent for `GameControlling` classes that are backed by `GCController`
/// objects. It defines the common methods used for by all controller profiles while the subclasses implement
/// the profile-specific methods.

class GameController : GameControlling {
    
    private(set) var controller: GCController?
    
    init(controller: GCController) {
        self.controller = controller
        controller.controllerPausedHandler = pauseButtonPressed
    }
    
    // MARK: - GameControlling
    
    var fireButtonPressedHandler: ButtonPressedHandler?
    var pauseButtonPressedHandler: ButtonPressedHandler?
    
    var leftButtonIsPressed: Bool {
        fatalError("leftButtonIsPressed must be implemented by subclass")
    }
    
    var rightButtonIsPressed: Bool {
        fatalError("leftButtonIsPressed must be implemented by subclass")
    }
    
    var fireButtonIsPressed: Bool {
        fatalError("leftButtonIsPressed must be implemented by subclass")
    }
    
    // MARK: - Protected methods
    
    func pauseButtonPressed(controller: GCController) {
        pauseButtonPressedHandler?(self)
    }
    
    func buttonAPressed(button: GCControllerButtonInput, value: Float, pressed: Bool) {
        if pressed {
            fireButtonPressedHandler?(self)
        }
    }
}