//
//  GameScene.swift
//  HCCCPongNJIT
//
//  Created by Samuel Folledo on 11/12/17.
//  Copyright © 2017 Samuel Folledo. All rights reserved.
//
//REMOVE MEEEEE
import SpriteKit
import GameplayKit

let BallCategoryName = "ball"
let MainCategoryName = "main"
let EnemyCategoryName = "enemy"
let BlockCategoryName = "block"
let GameMessageName = "gameMessage"
let PongTreesName = "pongTrees"

let MainCategory : UInt32 = 0x1 << 1
let BallCategory   : UInt32 = 0x1 << 2
let BottomCategory : UInt32 = 0x1 << 3
let TurtleCategory  : UInt32 = 0x1 << 0

let PongTreesCategory : UInt32 = 0x1 << 4

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ball = SKSpriteNode()
   
    var enemy = SKSpriteNode()
    var main = SKSpriteNode()
    
    var topLbl =  SKLabelNode()
    var btmLbL =  SKLabelNode()
    var score = [Int]()
    
    var deltaX = 30
    var deltaY = 30
    var TurtleLastSpawnTimeInterval: TimeInterval = 0
    var TurtleLastUpdateTimeInterval: TimeInterval = 0
    let tree = SKSpriteNode(imageNamed: "PongTrees")
    
    override func didMove(to view: SKView) {
        startGame()
        
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        enemy = self.childNode(withName: "enemy") as! SKSpriteNode
        main = self.childNode(withName: "main") as! SKSpriteNode
        topLbl = self.childNode(withName:  "topLabel") as! SKLabelNode
        btmLbL = self.childNode(withName: "bottomLabel") as! SKLabelNode
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        physicsWorld.contactDelegate = self
        
        ball.size = CGSize(width: 40, height: 40)
        ball.physicsBody?.applyImpulse(CGVector(dx: deltaX, dy: deltaY))
        ball.name = "ball"
        ball.physicsBody?.usesPreciseCollisionDetection = true
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        self.physicsBody = border
        
        
        
        ball.physicsBody!.categoryBitMask = BallCategory
        main.physicsBody!.categoryBitMask = MainCategory

        //trails
        let trailNode = SKNode()
        trailNode.zPosition = 1
        addChild(trailNode)
        let trail = SKEmitterNode(fileNamed: "BallTrail copy")!
        trail.targetNode = trailNode
        ball.addChild(trail)
        
        //trees
        tree.name = "tree"
        tree.size = CGSize(width:CGFloat(300), height: CGFloat(300))
        tree.position = CGPoint(x: -100, y: -200)
        addChild(tree)
        tree.physicsBody = SKPhysicsBody(circleOfRadius: (tree.size.width/2.5))
        tree.physicsBody!.allowsRotation = false
        tree.physicsBody!.friction = 0.0
        tree.physicsBody!.affectedByGravity = false
        tree.physicsBody!.isDynamic = false
        tree.physicsBody!.categoryBitMask = PongTreesCategory
        
        
        ball.physicsBody?.collisionBitMask = MainCategory | TurtleCategory | PongTreesCategory
        ball.physicsBody!.contactTestBitMask = MainCategory | TurtleCategory | PongTreesCategory
    }
    
//didBegin
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        // 2.
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        // React to contact with blocks
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == TurtleCategory {
            print("turtle hit!")
            breakIce(secondBody.node!)
        }
        
        
        
        // 2.
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == MainCategory {
            
            print("ball hit main")
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == PongTreesCategory {
            print("ball hit trees")
            magicTree()
        }
    }
    
    
    func magicTree(){
        let blink = SKAction.sequence([SKAction.fadeOut(withDuration: 1.0), SKAction.fadeIn(withDuration: 1.0)])
        ball.run(blink)
        return
    }

    
    func spawnTurtle() {
        let left = arc4random() % 2 //initiates the beginning and end properly
        let turtleString = (left == 0) ? "PongSheep2" : "PongSheep1"
        let turtleTexture = SKTexture(imageNamed: turtleString)
        // 1
        let turtle = SKSpriteNode(texture: turtleTexture)
        turtle.size = CGSize(width:CGFloat(80), height: CGFloat(80))
        // 2
        let minY = -500
        let maxY = 500
        let rangeY = maxY - minY
        let actualY = CGFloat(arc4random()).truncatingRemainder(dividingBy: CGFloat(rangeY + minY))
        // 3
        let turtleBeginning = (left == 0) ? -size.width/2 - turtle.size.width/2 : size.width/2 + turtle.size.width/2
        // 4
        turtle.position = CGPoint(x: turtleBeginning, y: actualY)
        turtle.name = "turtle"
        turtle.zPosition = 1
        addChild(turtle)
        // 5
        let minDuration = 8.0
        let maxDuration = 16.0
        let rangeDuration = maxDuration - minDuration
        let actualDuration = Double(arc4random()).truncatingRemainder(dividingBy: rangeDuration) + minDuration
        // 6
        let turtleEnding = (left == 0) ? size.width/2 + turtle.size.width/2 : -size.width/2 - turtle.size.width/2
        
        
        turtle.physicsBody = SKPhysicsBody(circleOfRadius: (turtle.size.width/2))
        turtle.physicsBody!.allowsRotation = false
        turtle.physicsBody!.friction = 0.0
        turtle.physicsBody!.affectedByGravity = false
        turtle.physicsBody!.isDynamic = false
        turtle.physicsBody!.categoryBitMask = TurtleCategory
        //turtle.zPosition = 2
        

        let actionMove = SKAction.move(to: CGPoint(x: turtleEnding, y: actualY), duration: actualDuration)
        let actionMoveDone = SKAction.removeFromParent()
        turtle.run(SKAction.sequence([actionMove, actionMoveDone]))

    }
    
    
    func updateWithTimeSinceLastUpdate(timeSinceLast: CFTimeInterval) {
        TurtleLastSpawnTimeInterval = timeSinceLast + TurtleLastSpawnTimeInterval
        if TurtleLastSpawnTimeInterval > 3.0 {
            TurtleLastSpawnTimeInterval = 0
            spawnTurtle()
        }
    }
    
    func breakIce(_ node: SKNode) {
        
        let particles = SKEmitterNode(fileNamed: "BrokenPlatform copy")!
        particles.position = node.position
        particles.zPosition = 3
        addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.removeFromParent()]))
        node.removeFromParent()
    }
    
    

    func startGame() {
        score = [0,0]
        topLbl.text = "\(score[1])"
        btmLbL.text = "\(score[0])"
        ball.physicsBody?.applyImpulse(CGVector(dx: deltaX , dy: deltaY))
    }
    
    func addScore(playerWhoWon : SKSpriteNode){
        
        ball.position = CGPoint(x: 0, y: 0)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        if playerWhoWon == main {
            score[0] += 1
            ball.physicsBody?.applyImpulse(CGVector(dx: deltaX, dy: deltaY))
        }
        else if playerWhoWon == enemy {
            score[1] += 1
            ball.physicsBody?.applyImpulse(CGVector(dx: -deltaX , dy: -deltaY))
        }
        
        topLbl.text = "\(score[1])"
        btmLbL.text = "\(score[0])"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            main.run(SKAction.moveTo(x: location.x, duration: 0.2))
            
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            main.run(SKAction.moveTo(x: location.x, duration: 0.2))
            
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        var timeSinceLast = currentTime - TurtleLastUpdateTimeInterval
        TurtleLastUpdateTimeInterval = currentTime
        if timeSinceLast > 1.0 {
            timeSinceLast = 1.0 / 60.0
            TurtleLastUpdateTimeInterval = currentTime
        }
        updateWithTimeSinceLastUpdate(timeSinceLast: timeSinceLast)
        enemy.run(SKAction.moveTo(x: ball.position.x, duration: 0.7))
        
        if ball.position.y <= main.position.y - 25{
            addScore(playerWhoWon: enemy)
        }
        else if ball.position.y >= enemy.position.y + 25 {
            addScore(playerWhoWon: main)
        }
    }
}
