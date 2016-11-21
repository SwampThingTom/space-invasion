//
//  GameControlling.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/21/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import GameController

typealias ButtonPressedHandler = (GameControlling) -> Void

/// The `GameControlling` protocol defines the interface used to monitor the controls
/// used for the Space Invasion game.

protocol GameControlling {
    
    /// The backing `GCController` used by this object, or nil if the controls are
    /// backed by an interface that is not a game controller.
    var controller: GCController? { get }
    
    var leftButtonIsPressed: Bool { get }
    var rightButtonIsPressed: Bool { get }
    var fireButtonIsPressed: Bool { get }
    
    var fireButtonPressedHandler: ButtonPressedHandler? { get set }
    var pauseButtonPressedHandler: ButtonPressedHandler? { get set }
}
