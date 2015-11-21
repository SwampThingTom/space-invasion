//
//  GameControlling.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/21/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

typealias ButtonPressedHandler = () -> Void

protocol GameControlling {
    
    var leftButtonIsPressed: Bool { get }
    var rightButtonIsPressed: Bool { get }
    var fireButtonIsPressed: Bool { get }
    var menuButtonIsPressed: Bool { get }
    
    var fireButtonPressedHandler: ButtonPressedHandler? { get set }
    var menuButtonPressedHandler: ButtonPressedHandler? { get set }
    var playPauseButtonPressedHandler: ButtonPressedHandler? { get set }
}