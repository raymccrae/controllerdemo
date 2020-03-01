//
//  GameScene.swift
//  SprocketLeague
//
//  Created by Demo on 26/02/2020.
//  Copyright © 2020 Demo. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameController

struct ThumbstickAxis {
    let x: CGFloat
    let y: CGFloat
}

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var currentLeftThumbstickAxis = ThumbstickAxis(x: 0, y: 0)
    private var player2CurrentLeftThumbstickAxis = ThumbstickAxis(x: 0, y: 0)
    private var player1Position = CGPoint.zero
    private var player2Position = CGPoint.zero
    
    
    
    private var shapePosition = CGPoint(x: 0, y: 0)
    
    override func didMove(to view: SKView) {
        ObserveForGameControllers()
    }
    
    func ObserveForGameControllers() {
        NotificationCenter.default.addObserver(self, selector: #selector(connectControllers), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectControllers), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }
    
    // This Function is called when a controller is connected to the Apple TV
    @objc func connectControllers() {
        //Unpause the Game if it is currently paused
        self.isPaused = false
        //Used to register the Nimbus Controllers to a specific Player Number
        var indexNumber = 0
        // Run through each controller currently connected to the system
        for controller in GCController.controllers() {
            //Check to see whether it is an extended Game Controller (Such as a Nimbus)
            if controller.extendedGamepad != nil {
                controller.playerIndex = GCControllerPlayerIndex.init(rawValue: indexNumber)!
                indexNumber += 1
                setupControllerControls(controller: controller)
            }
        }
    }
    
    // Function called when a controller is disconnected from the Apple TV
    @objc func disconnectControllers() {
        // Pause the Game if a controller is disconnected ~ This is mandated by Apple
        self.isPaused = true
    }
    
    func setupControllerControls(controller: GCController) {
        //Function that check the controller when anything is moved or pressed on it
        controller.extendedGamepad?.valueChangedHandler = {
            (gamepad: GCExtendedGamepad, element: GCControllerElement) in
            // Add movement in here for sprites of the controllers
            self.controllerInputDetected(gamepad: gamepad, element: element, index: controller.playerIndex.rawValue)
        }
    }
    
    func controllerInputDetected(gamepad: GCExtendedGamepad, element: GCControllerElement, index: Int) {
        var x: CGFloat = 0
        var y: CGFloat = 0
        if (gamepad.leftThumbstick == element) {
            if index == 0 {
                            currentLeftThumbstickAxis = ThumbstickAxis(x: CGFloat(gamepad.leftThumbstick.xAxis.value), y: CGFloat(gamepad.leftThumbstick.yAxis.value))
                
            } else {
                            player2CurrentLeftThumbstickAxis = ThumbstickAxis(x: CGFloat(gamepad.leftThumbstick.xAxis.value), y: CGFloat(gamepad.leftThumbstick.yAxis.value))
                
            }
            if (gamepad.leftThumbstick.xAxis.value > 0) {
               x = 1
                print("Controller: \(index), LeftThumbstickXAxis: \(gamepad.leftThumbstick.xAxis)")
            }
            else if (gamepad.leftThumbstick.xAxis.value < 0)
            {
                x = -1
            }

        }
        // Right Thumbstick
        if (gamepad.rightThumbstick == element)
        {
            if (gamepad.rightThumbstick.xAxis.value != 0)
            {
                print("Controller: \(index), rightThumbstickXAxis: \(gamepad.rightThumbstick.xAxis)")
            }
        }
            // D-Pad
        else if (gamepad.dpad == element)
        {
            if (gamepad.dpad.xAxis.value != 0)
            {
                print("Controller: \(index), D-PadXAxis: \(gamepad.rightThumbstick.xAxis)")
            }
            else if (gamepad.dpad.xAxis.value == 0)
            {
                // YOU CAN PUT CODE HERE TO STOP YOUR PLAYER FROM MOVING
            }
        }
            // A-Button
        else if (gamepad.buttonA == element)
        {
            if (gamepad.buttonA.value != 0)
            {
                print("Controller: \(index), A-Button Pressed!")
            }
        }
            // B-Button
        else if (gamepad.buttonB == element)
        {
            if (gamepad.buttonB.value != 0)
            {
                print("Controller: \(index), B-Button Pressed!")
            }
        }
        else if (gamepad.buttonY == element)
        {
            if (gamepad.buttonY.value != 0)
            {
                print("Controller: \(index), Y-Button Pressed!")
            }
        }
        else if (gamepad.buttonX == element)
        {
            if (gamepad.buttonX.value != 0)
            {
                print("Controller: \(index), X-Button Pressed!")
            }
        }
    }
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    func drawShape(xd: CGFloat, yd: CGFloat, from position: CGPoint) {
        
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = position
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
        
        player1Position.x += currentLeftThumbstickAxis.x
        player1Position.y += currentLeftThumbstickAxis.y
        drawShape(xd: currentLeftThumbstickAxis.x, yd: currentLeftThumbstickAxis.y, from: player1Position)
        
        player2Position.x += player2CurrentLeftThumbstickAxis.x
        player2Position.y += player2CurrentLeftThumbstickAxis.y
        drawShape(xd: player2CurrentLeftThumbstickAxis.x, yd: player2CurrentLeftThumbstickAxis.y, from: player2Position)
    }
}
