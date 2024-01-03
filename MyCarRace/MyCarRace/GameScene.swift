//
//  GameScene.swift
//  MyCarRace
//
//  Created by ebulut on 3/1/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate {
    
    var road: SKSpriteNode!
    var points = 0
    var lastItemAddedTime: TimeInterval = 0

    var label = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var isGameOver = false
    

    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        animateRoad()
        addCar()
        addPhysicsAndBitMask()
        
        // Initialize and add points label
        
        label = SKLabelNode(text: "Points: \(points)")
        label.position = CGPoint(x: self.size.width / 2, y: self.size.height - 75)
        addChild(label)

        updatePointsLabel()
    }
    
    func animateRoad(){
        
        // first road image
        road = SKSpriteNode(imageNamed: "road")
        road.setScale(0.6)
        road.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        addChild(road)
        
        // create the second road image on top of the other and animate down
        // .....
        let road2 = SKSpriteNode(imageNamed: "road")
        road2.setScale(0.6)
        road2.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + road.size.height)
        addChild(road2)

        // Define the actions for moving down and moving back up
        let moveDownAction = SKAction.moveBy(x: 0, y: -road.size.height, duration: 3.0)
        let moveUpAction = SKAction.moveBy(x: 0, y: road.size.height, duration: 0.0)

        // Create a sequence to move down and move up
        let sequence = SKAction.sequence([moveDownAction, moveUpAction])

        // Create a repeating action to repeat the sequence forever
        let repeatAction = SKAction.repeatForever(sequence)

        // Run the repeating action on both road images
        road.run(repeatAction)
        road2.run(repeatAction)
        
    }
    
    func addCar(){
        
        //create car sprite and define position
        let car = SKSpriteNode(imageNamed: "bluecar")
        car.position = CGPoint(x: self.size.width / 2, y: 100)
        // play with order of adding or with zPosition if not showing up
        car.zPosition = 1

        // use setScale if sprite node image is bigger
        // 0.15 is good scale for car image
        car.setScale(0.15)
        
        car.physicsBody = SKPhysicsBody(rectangleOf: car.size)
        car.physicsBody?.categoryBitMask = PCategory.Car
        car.physicsBody?.contactTestBitMask = PCategory.Barrier | PCategory.Grease | PCategory.Fuel
        car.physicsBody?.collisionBitMask = 0
        car.physicsBody?.affectedByGravity = false
        car.physicsBody?.isDynamic = true
        
        addChild(car)
        
        if points < 0{
            showGameOverScreen()
        }
        
        
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view?.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view?.addGestureRecognizer(swipeRight)
        
        self.car = car
    }
    
    func showGameOverScreen() {
        let transition = SKTransition.fade(withDuration: 1.0)
        let newScene = GameOverScene(size: self.size)
        newScene.scaleMode = self.scaleMode
        self.view?.presentScene(newScene, transition: transition)
    }



    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            // Restart the game
            isGameOver = false
            points = 0
            updatePointsLabel()

            // Remove all nodes except the road
            for child in children {
                if child != road {
                    child.removeFromParent()
                }
            }

            addCar() // Restart the game
        }
    }


    
    
    var car: SKSpriteNode?
    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer){
        guard let car = car
        else{ return}
        let move: CGFloat = 100.0
        
        switch sender.direction{
            case .left:
            if car.position.x > self.size.width / 3{
                car.position.x -= move
            }
            
            case .right:
            if car.position.x < (2*self.size.width)/3 {
                car.position.x += move
            }
        default:
            break
        }
    }
    
    func addItemsRandomly(){
        
        // this is one way - feel free to update
        let randLoc = Int.random(in: 1...3)
        
        //three possible locations (optimized for iphone pro 14)
        let loc = -7+randLoc*100
        let point = CGPoint(x: CGFloat(loc), y: CGFloat(self.size.height))
        
        // decides which one (barrier, fuel, grease) to add
        // in one of three possible locations/lanes
        
        let whichItem = Int.random(in: 1...3)
        if whichItem == 1 {
            addBarrier(point: point)
        }
        else if whichItem == 2 {
            addFuel(point: point)
        }
        else{
            addGrease(point: point)
        }
        
        
    }
    
    func addBarrier(point: CGPoint){
        let barrier = SKSpriteNode(imageNamed: "barrier")
        barrier.position = point
        barrier.setScale(0.15)
        addChild(barrier)
        
        // Set up physics for the barrier
        barrier.physicsBody = SKPhysicsBody(rectangleOf: barrier.size)
        barrier.physicsBody?.categoryBitMask = PCategory.Barrier
        barrier.physicsBody?.contactTestBitMask = PCategory.Car
        barrier.physicsBody?.collisionBitMask = 0
        barrier.physicsBody?.affectedByGravity = false
        barrier.physicsBody?.isDynamic = true

        
        // Move the barrier down the screen
        let moveDownAction = SKAction.moveBy(x: 0, y: -self.size.height, duration: 3.0)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveDownAction, removeAction])
        barrier.run(sequence)
    }

    
    func addFuel(point: CGPoint){
        let fuel = SKSpriteNode(imageNamed: "fuel")
        fuel.position = point
        fuel.setScale(0.15)
        addChild(fuel)
        
        // Set up physics for the barrier
        fuel.physicsBody = SKPhysicsBody(rectangleOf: fuel.size)
        fuel.physicsBody?.categoryBitMask = PCategory.Fuel
        fuel.physicsBody?.contactTestBitMask = PCategory.Car
        fuel.physicsBody?.collisionBitMask = 0
        fuel.physicsBody?.affectedByGravity = false
        fuel.physicsBody?.isDynamic = true

        
        // Move the barrier down the screen
        let moveDownAction = SKAction.moveBy(x: 0, y: -self.size.height, duration: 3.0)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveDownAction, removeAction])
        fuel.run(sequence)
        
    }
    
    func addGrease(point: CGPoint){
        let grease = SKSpriteNode(imageNamed: "grease")
        grease.position = point
        grease.setScale(0.15)

        addChild(grease)
        
        // Set up physics for the barrier
        grease.physicsBody = SKPhysicsBody(rectangleOf: grease.size)
        grease.physicsBody?.categoryBitMask = PCategory.Grease
        grease.physicsBody?.contactTestBitMask = PCategory.Car
        grease.physicsBody?.collisionBitMask = 0
        grease.physicsBody?.affectedByGravity = false
        grease.physicsBody?.isDynamic = true

        
        // Move the barrier down the screen
        let moveDownAction = SKAction.moveBy(x: 0, y: -self.size.height, duration: 3.0)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveDownAction, removeAction])
        grease.run(sequence)
        
    }
    
    
    func addPhysicsAndBitMask(){
        
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard !isGameOver else{
            return
        }
        
        if (contact.bodyA.categoryBitMask == PCategory.Car && contact.bodyB.categoryBitMask == PCategory.Barrier) ||
           (contact.bodyB.categoryBitMask == PCategory.Barrier && contact.bodyA.categoryBitMask == PCategory.Car) {
            print("Car hit barrier")
            points -= 1
            updatePointsLabel()


        } else if (contact.bodyA.categoryBitMask == PCategory.Car && contact.bodyB.categoryBitMask == PCategory.Grease) ||
                   (contact.bodyB.categoryBitMask == PCategory.Grease && contact.bodyA.categoryBitMask == PCategory.Car) {
            print("Car hit grease")
            points -= 1
            updatePointsLabel()

        } else if (contact.bodyA.categoryBitMask == PCategory.Car && contact.bodyB.categoryBitMask == PCategory.Fuel) ||
                   (contact.bodyB.categoryBitMask == PCategory.Fuel && contact.bodyA.categoryBitMask == PCategory.Car) {
            print("Car hit fuel")
            points += 1
            updatePointsLabel()
        }
        
        if points < 0{
            print("game over")
            showGameOverScreen()
            isGameOver = true
            removeAllChildren()
        }
    }


    
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else {
            return
        }

        // Called before each frame is rendered
        // Add items randomly every few seconds
        let randomTimeInterval = TimeInterval.random(in: 1.0...3.0) // Adjust the range as needed
        let currentTime = Date.timeIntervalSinceReferenceDate

        if currentTime - lastItemAddedTime > randomTimeInterval {
            addItemsRandomly()
            lastItemAddedTime = currentTime
        }
    }
     

    
    func updatePointsLabel() {
        label.text = "Points: \(points)"
    }


    
    struct PCategory {
        static let Car: UInt32 = 1
        static let Barrier: UInt32 = 2
        static let Fuel: UInt32 = 4
        static let None: UInt32 = 8
        static let Grease: UInt32 = 16
    }
    
    
}

class GameOverScene: SKScene {
    
    override func didMove(to view: SKView) {
        let gameOverLabel = SKLabelNode(text: "GAME OVER")
        gameOverLabel.fontSize = 36
        gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + 50)
        addChild(gameOverLabel)
        
        let restartLabel = SKLabelNode(text: "Tap to Restart")
        restartLabel.fontSize = 24
        restartLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 50)
        addChild(restartLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let view = self.view {
            let newScene = GameScene(size: self.size)
            newScene.scaleMode = .aspectFill
            view.presentScene(newScene)
        }
    }
}


