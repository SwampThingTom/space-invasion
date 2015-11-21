//
//  GameControllers.swift
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/21/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import GameController

protocol GameControllersDelegate {
    func connectedController(controller: GameControlling)
    func disconnectedController(controller: GameControlling)
}

class GameControllers {
    
    var delegate: GameControllersDelegate?
    var defaultController: GameControlling?
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
        // TODO: Enumerate connected controllers
        NSNotificationCenter.defaultCenter().addObserverForName(
            "GCControllerDidConnectNotification",
            object: nil,
            queue: nil) { (sender: AnyObject) in
                self.addedController(sender.object)
        }
        
        if let controller = GCController.controllers().first as GCController! {
            defaultController = GameController(controller: controller)
        }
    }
    
    private func addedController(sender: AnyObject?) {
        guard let controller = sender as? GCController else {
            return
        }
        let gameController = GameController(controller: controller)
        if defaultController == nil {
            defaultController = gameController
        }
        delegate?.connectedController(gameController)
    }
}
