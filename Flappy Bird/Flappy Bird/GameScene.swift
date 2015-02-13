//
//  GameScene.swift
//  Flappy Bird
//
//  Created by George Lo on 2/6/15.
//  Copyright (c) 2015 Purdue iOS Dev Club. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var birdNode: SKSpriteNode?
    
    let verticalPipeGap = 100
    let pipeTexture1: SKTexture!
    let pipeTexture2: SKTexture!
    let moveAndRemovePipes: SKAction!
    
    // 0000 0001
    let birdCategory = UInt32(1 << 0)  //0001
    let worldCategory = UInt32(1 << 1) // 0010
    let pipeCategory = UInt32(1 << 2) //0100
    
    let moving: SKNode!
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.physicsWorld.gravity = CGVectorMake(0, -5)
        self.physicsWorld.contactDelegate = self
        
        moving = SKNode()
        self.addChild(moving)
        
        // Background color
        let skyBlueColor = SKColor(red: 135.0/255, green: 206.0/255, blue: 250.0/255, alpha: 1)
        self.backgroundColor = skyBlueColor
        
        // Bird Animation
        let birdTexture1 = SKTexture(image: UIImage(named: "Bird1")!)
        birdTexture1.filteringMode = SKTextureFilteringMode.Nearest
        let birdTexture2 = SKTexture(image: UIImage(named: "Bird2")!)
        birdTexture2.filteringMode = SKTextureFilteringMode.Nearest
        let flappingAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.2))
        
        
        /*
        for var i = 0; i <= numOfGrounds; i++ {
        }*/
        
        
        // Ground
        let groundTexture = SKTexture(image: UIImage(named: "Ground")!)
        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let moveGroundSprite = SKAction.moveByX(-groundTexture.size().width, y: 0, duration: Double(0.02 * groundTexture.size().width*2))
        let resetGroundSprite = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0)
        let moveGroundForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite, resetGroundSprite]))
        
        let numOfGrounds: Int = Int(self.frame.size.width / groundTexture.size().width) + 1
        for i in 0...numOfGrounds {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.setScale(2.0)
            sprite.position = CGPointMake(CGFloat(i) * sprite.size.width, sprite.size.height / 2)
            sprite.runAction(moveGroundForever)
            moving.addChild(sprite)
        }
        
        // Skyline
        let skylineTexture = SKTexture(image: UIImage(named: "Skyline")!)
        skylineTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let moveSkylineSprite = SKAction.moveByX(-skylineTexture.size().width, y: 0, duration: Double(0.1 * skylineTexture.size().width*2))
        let resetSkylineSprite = SKAction.moveByX(skylineTexture.size().width, y: 0, duration: 0)
        let moveSkylineForever = SKAction.repeatActionForever(SKAction.sequence([moveSkylineSprite, resetSkylineSprite]))
        
        let numOfSkylines: Int = Int(self.frame.size.width / skylineTexture.size().width) + 1
        for i in 0...numOfSkylines {
            let sprite = SKSpriteNode(texture: skylineTexture)
            sprite.setScale(2.0)
            sprite.zPosition = -20
            sprite.position = CGPointMake(CGFloat(i) * sprite.size.width, sprite.size.height / 2 + groundTexture.size().height * 2)
            sprite.runAction(moveSkylineForever)
            moving.addChild(sprite)
        }
        
        // Bird
        birdNode = SKSpriteNode(texture: birdTexture1)
        birdNode?.setScale(2.0)
        birdNode?.position = CGPointMake(self.frame.width / 4, CGRectGetMidY(self.frame))
        birdNode?.runAction(flappingAnimation)
        
        birdNode?.physicsBody = SKPhysicsBody(circleOfRadius: birdNode!.frame.height / 2)
        birdNode?.physicsBody?.dynamic = true
        birdNode?.physicsBody?.allowsRotation = false
        
        self.addChild(birdNode!)
        
        let dummy = SKNode()
        dummy.position = CGPointMake(0, groundTexture.size().height)
        dummy.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.width, groundTexture.size().height * 2))
        dummy.physicsBody?.dynamic = false
        self.addChild(dummy)
        
        pipeTexture1 = SKTexture(imageNamed: "Pipe1")
        pipeTexture1.filteringMode = SKTextureFilteringMode.Nearest
        pipeTexture2 = SKTexture(imageNamed: "Pipe2")
        pipeTexture2.filteringMode = SKTextureFilteringMode.Nearest
        
        let distanceToMove = self.frame.width + 2 * pipeTexture1.size().width
        let movePipes = SKAction.moveByX(-distanceToMove, y: 0, duration: Double(0.01 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        let spawn = SKAction.runBlock(self.spawnPipe)
        let delay = SKAction.waitForDuration(2.0)
        let spawnAndDelayForever = SKAction.repeatActionForever(SKAction.sequence([spawn, delay]))
        self.runAction(spawnAndDelayForever)
    }
    
    func spawnPipe() {
        let pipePair = SKNode()
        pipePair.position = CGPointMake(self.frame.size.width + pipeTexture1.size().width, 0)
        pipePair.zPosition = -10
        
        let y = arc4random() % UInt32(self.frame.size.height / 3.0)
        
        let pipe1 = SKSpriteNode(texture: pipeTexture1)
        pipe1.setScale(2.0)
        pipe1.position = CGPointMake(0, CGFloat(y))
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture1.size())
        pipe1.physicsBody?.dynamic = false
        pipe1.physicsBody?.categoryBitMask = pipeCategory
        pipe1.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(pipe1)
        
        let pipe2 = SKSpriteNode(texture: pipeTexture2)
        pipe2.setScale(2.0)
        pipe2.position = CGPointMake(0, CGFloat(y) + pipe1.size.height + CGFloat(verticalPipeGap))
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture2.size())
        pipe2.physicsBody?.dynamic = false
        pipe2.physicsBody?.categoryBitMask = pipeCategory
        pipe2.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(pipe2)
        
        pipePair.runAction(moveAndRemovePipes)
        
        moving.addChild(pipePair)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        birdNode?.physicsBody?.velocity = CGVectorMake(0, 0)
        birdNode?.physicsBody?.applyImpulse(CGVectorMake(0, 6))
    }
    
    func clamp(#min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if value > max {
            return max
        } else if value < min {
            return min
        }
        return value
    }
    
    override func update(currentTime: CFTimeInterval) {
        if moving.speed > 0 {
            birdNode!.zRotation = self.clamp(min: -1, max: 0.8, value: (birdNode!.physicsBody!.velocity.dy * (birdNode!.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001)))
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if moving.speed > 0 {
            moving.speed = 0
            
            self.removeActionForKey("flash")
            self.runAction(SKAction.sequence([
                SKAction.repeatAction(SKAction.sequence([
                    SKAction.runBlock({
                        self.backgroundColor = UIColor.redColor()
                    }),
                    SKAction.waitForDuration(0.05),
                    SKAction.runBlock({
                        self.backgroundColor = SKColor(red: 135.0/255, green: 206.0/255, blue: 250.0/255, alpha: 1)
                    }),
                    SKAction.waitForDuration(0.05)
                ]), count: 4)
            ]))
        }
    }
}
