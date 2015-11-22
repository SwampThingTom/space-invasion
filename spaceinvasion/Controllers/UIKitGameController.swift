//
//  UIKitGameController.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/21/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import SpriteKit
import GameController

/// `UIKitGameController` is an adapter that converts `UIKit` gestures to game controls.
///
/// To use, set the `view` property to the `UIView` that will manage the touch handling. That view must forward
/// touch event callbacks to its `UIKitGameController` instance.

class UIKitGameController : GameControlling {
    
    // MARK: - GameControlling
    
    var controller: GCController? = nil
    
    var fireButtonPressedHandler: ButtonPressedHandler?
    var menuButtonPressedHandler: ButtonPressedHandler?
    var pauseButtonPressedHandler: ButtonPressedHandler?
    
    var leftButtonIsPressed = false
    var rightButtonIsPressed = false
    var fireButtonIsPressed = false
    var menuButtonIsPressed = false
    
    // MARK: - Touch handling
    
    /// The view that will be used for touch handling and gesture recognizers.
    var view: UIView? {
        didSet {
            addGestureRecognizers()
        }
    }
    
    private var touchStartLocation = CGPointZero
    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        touchStartLocation = touch.locationInView(nil)
    }
    
    func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchEpsilon: CGFloat = 60
        let touchLocation = touch.locationInView(nil)
        
        if touchLocation.x < touchStartLocation.x - touchEpsilon {
            leftButtonIsPressed = true
            rightButtonIsPressed = false
        }
        else if touchLocation.x > touchStartLocation.x + touchEpsilon {
            leftButtonIsPressed = false
            rightButtonIsPressed = true
        }
        else {
            leftButtonIsPressed = false
            rightButtonIsPressed = false
        }
    }
    
    func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        leftButtonIsPressed = false
        rightButtonIsPressed = false
    }
    
    func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        leftButtonIsPressed = false
        rightButtonIsPressed = false
    }
    
    // MARK: - Gesture recognizers
    
    private func addGestureRecognizers() {
        addGestureRecognizerForButton(.Select, action: "selectButtonPressed")
        addGestureRecognizerForButton(.Menu, action: "menuButtonPressed")
    }
    
    private func selectButtonPressed() {
        fireButtonPressedHandler?(self)
    }
    
    private func menuButtonPressed() {
        menuButtonPressedHandler?(self)
    }
    
    private func addGestureRecognizerForButton(button: UIPressType, action: Selector) {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: action)
        gestureRecognizer.allowedPressTypes = [NSNumber(integer: button.rawValue)]
        view?.addGestureRecognizer(gestureRecognizer)
    }
}