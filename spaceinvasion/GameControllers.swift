//
//  GameControllers.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/21/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import GameController

/// Used to notify the delegate of a `GameControllers` instance that one of the connected controllers
/// has pressed a particular button. The delegate can use that to make the controller responsible for
/// other actions related to the button press.

protocol GameControllersDelegate {
    
    func menuButtonPressed(controller: GameControlling)
    func pauseButtonPressed(controller: GameControlling)
    func fireButtonPressed(controller: GameControlling)
}

/// Manages the set of connected `GameControlling` objects.

class GameControllers {
    
    /// The delegate that will be notified when a connected controller button is pressed.
    var delegate: GameControllersDelegate?
    
    /// The list of connected `GameControlling` objects.
    private(set) var connectedControllers = [GameControlling]()
    
    /// A `GameControlling` object backed by `UIKit` touches and gesture recognizers.
    lazy var uiKitController = UIKitGameController()
    
    private static var connectedControllers: GameControllers?
    static func controllers() -> GameControllers {
        guard let controllers = connectedControllers as GameControllers! else {
            connectedControllers = GameControllers()
            return connectedControllers!
        }
        return controllers
    }
    
    private init() {
        NSNotificationCenter.defaultCenter().addObserverForName(
            "GCControllerDidConnectNotification",
            object: nil,
            queue: nil) { (sender: AnyObject) in self.controllerDidConnect(sender.object) }
        
        NSNotificationCenter.defaultCenter().addObserverForName(
            "GCControllerDidDisconnectNotification",
            object: nil,
            queue: nil) { (sender: AnyObject) in self.controllerDidDisconnect(sender.object) }
        
        for controller in GCController.controllers() {
            if let gameController = gameControllerForController(controller) as GameControlling! {
                addController(gameController)
            }
        }
    }
    
    private func controllerDidConnect(sender: AnyObject?) {
        guard let controller = sender as? GCController else {
            return
        }
        guard let gameController = gameControllerForController(controller) as GameControlling! else {
            return
        }
        addController(gameController)
    }
    
    private func controllerDidDisconnect(sender: AnyObject?) {
        guard let controller = sender as? GCController else {
            return
        }
        connectedControllers = connectedControllers.filter() { $0.controller !== controller }
        
        // TODO: Notify delegate that controller is no longer connected
    }
    
    private func addController(var gameController: GameControlling) {
        connectedControllers.append(gameController)
        gameController.menuButtonPressedHandler = menuButtonPressedOnController
        gameController.pauseButtonPressedHandler = pauseButtonPressedOnController
        gameController.fireButtonPressedHandler = fireButtonPressedOnController
    }
    
    private func menuButtonPressedOnController(controller: GameControlling) {
        delegate?.menuButtonPressed(controller)
    }
    
    private func pauseButtonPressedOnController(controller: GameControlling) {
        delegate?.pauseButtonPressed(controller)
    }
    
    private func fireButtonPressedOnController(controller: GameControlling) {
        delegate?.fireButtonPressed(controller)
    }
    
    private func gameControllerForController(controller: GCController) -> GameControlling? {
        if let _ = controller.microGamepad as GCMicroGamepad! {
            return MicroGameController(controller: controller)
        }
        if let _ = controller.gamepad as GCGamepad! {
            return StandardGameController(controller: controller)
        }
        return nil
    }
}