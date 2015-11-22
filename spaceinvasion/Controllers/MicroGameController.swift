//
//  MicroGameController
//  spaceinvasion
//
//  Created by Thomas Aylesworth on 11/21/15.
//  Copyright © 2015 Thomas H Aylesworth. All rights reserved.
//

import GameController

/// `MicroGameController` provides `GameControlling` support for the Apple TV remote,
/// as well as other `GCController` objects that support the micro gamepad profile.

class MicroGameController : GameController {
    
    private let gamepad: GCMicroGamepad
    
    override init(controller: GCController) {
        gamepad = controller.microGamepad!
        super.init(controller: controller)
        gamepad.buttonA.pressedChangedHandler = buttonAPressed
        gamepad.buttonX.pressedChangedHandler = buttonXPressed
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

    override var menuButtonIsPressed: Bool {
        return gamepad.buttonX.pressed
    }
}