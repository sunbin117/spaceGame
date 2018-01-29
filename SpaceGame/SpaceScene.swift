//
//  SpaceScene.swift
//  SpaceGame
//
//  Created by 韩小胜 on 2018/1/22.
//  Copyright © 2018年 sun. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class SpaceScene: SKScene {
    
    var rockArr = [SKShapeNode]()
    var StoneArr = [SKSpriteNode]()
    let player = SKSpriteNode.init(imageNamed: "airShip")
    var playerWashit = false
    
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        createScene()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let startLocation = touch.previousLocation(in: self)
        let endLocation = touch.location(in: self)
        let changeX = startLocation.x - endLocation.x
        let changeY = startLocation.y - endLocation.y
        player.position.x -= changeX
        player.position.y -= changeY
    }
    
    func createScene() {
        let spaceship = newSpaceShip()
        spaceship.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        spaceship.zPosition = 1
        self.addChild(spaceship)
        
        let background = SKSpriteNode.init(imageNamed: "space")
        background.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        background.zPosition = -1
        self.addChild(background)
        
        // 生成陨石
        Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(SpaceScene.addRock), userInfo: nil, repeats: true)
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SpaceScene.creatMeteorite), userInfo: nil, repeats: true)
        
        // 生成背景
        if let particles = SKEmitterNode.init(fileNamed: "SpaceDust") {
            particles.advanceSimulationTime(24)
            particles.position.y = self.size.height
            particles.position.x = self.size.width / 2
            self.addChild(particles)
        }
        
    }
    // 创建陨石
    @objc func addRock() {
        let rock = SKShapeNode()
        rock.path = CGPath(roundedRect: CGRect(x:-2,y:-4,width:4,height:8),
                           cornerWidth: 2,cornerHeight:4,transform:nil)
        rock.strokeColor = SKColor.white
        rock.fillColor = SKColor.brown
        let w = self.size.width
        let h = self.size.height
        // 随机出现位置
        let x = CGFloat(arc4random()).truncatingRemainder(dividingBy: w)
        rock.position = CGPoint(x:x,y:h)
        rock.name = "rock"
        rock.physicsBody = SKPhysicsBody(circleOfRadius:4)
        rock.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(rock)
        self.rockArr.append(rock)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // 移除屏幕外陨石
        for rock in rockArr {
            if rock.position.y < 0 {
                rock.removeFromParent()
                rockArr.remove(at: rockArr.index(of: rock)!)
            }
        }
        
        for stone in StoneArr {
            if stone.position.y < 0 {
                stone.removeFromParent()
                StoneArr.remove(at: StoneArr.index(of: stone)!)
            }
        }
    }
    
    @objc func creatMeteorite() {
        let screenHeight = self.size.height;
        let screenWidth = self.size.width / 2;
        let randomDistribution = GKRandomDistribution.init(lowestValue: Int(-screenWidth), highestValue: Int(2 * screenWidth))
        let randomSize = GKRandomDistribution.init(lowestValue: 3, highestValue: 7)
        let rockSprite = SKSpriteNode.init(imageNamed: "asteroid")
        
        var candidatePosition: CGPoint?
        for _ in 0..<10 {
            let testPoint = CGPoint(x: CGFloat(randomDistribution.nextInt()), y: screenHeight)
            if locationIsEmpty(potin: testPoint) {
                candidatePosition = testPoint
                break
            }
        }
        
        guard candidatePosition != nil else { return }
        let scale = CGFloat(randomSize.nextInt()) / 10
        rockSprite.position = candidatePosition!
        rockSprite.zPosition = 1
        rockSprite.setScale(scale)
        rockSprite.physicsBody = SKPhysicsBody.init(texture: rockSprite.texture ?? SKTexture(), size: rockSprite.size)
        rockSprite.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        rockSprite.physicsBody?.collisionBitMask = PhysicsCategory.Player
        rockSprite.physicsBody?.velocity = CGVector(dx: 0, dy: CGFloat(-abs(randomDistribution.nextInt())))
        rockSprite.physicsBody?.density = 1
        rockSprite.physicsBody?.affectedByGravity = false
        rockSprite.physicsBody?.linearDamping = 0
        rockSprite.physicsBody?.restitution = 0
        self.addChild(rockSprite)
        self.StoneArr.append(rockSprite)
    }
    
    func locationIsEmpty(potin: CGPoint) -> Bool {
        let nodes = self.nodes(at: potin)
        if let node = nodes.first, node.physicsBody?.categoryBitMask == PhysicsCategory.Enemy || node.physicsBody?.categoryBitMask == PhysicsCategory.Energy {
            return false
        }
        return true
    }
    
    // 创建飞船的类
    func newSpaceShip()->SKSpriteNode{

        let ship = player

        ship.size = CGSize.init(width: 40, height: 40)
        
        let light1 = newLight()
        light1.position = CGPoint(x:-20,y:6)
        ship.addChild(light1)
        
        let light2 = newLight()
        light2.position = CGPoint(x:20,y:6)
        ship.addChild(light2)
        
        // 物理系统
        ship.physicsBody = SKPhysicsBody(circleOfRadius:15)
        ship.physicsBody?.isDynamic = false
        ship.physicsBody?.categoryBitMask = PhysicsCategory.Player
        ship.physicsBody?.collisionBitMask = PhysicsCategory.Enemy
        ship.physicsBody?.density = 1
        ship.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        ship.zPosition = 1
        
        return ship
    }
    
    // 创建灯光
    func newLight()->SKShapeNode{
        let light = SKShapeNode()
        light.path = CGPath(roundedRect:CGRect(x:-2,y:-4,width:4,height:8),
                            cornerWidth:2,cornerHeight:4,transform: nil)
        light.strokeColor = SKColor.white
        light.fillColor = SKColor.yellow
        // 创建忽明忽暗的动作
        let blink = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.fadeIn(withDuration: 0.25)
            ])
        let blinkForever = SKAction.repeatForever(blink)
        light.run(blinkForever)
        return light
    }
    
    func playerHit(node: SKNode) {
        print("playerHit")
        if node.physicsBody?.categoryBitMask == PhysicsCategory.Enemy && !self.playerWashit {
            let nodeVelocity = node.physicsBody?.velocity ?? CGVector.zero
            let velocity = CGVector.init(dx: nodeVelocity.dx, dy: nodeVelocity.dy)
            let veolcityAction = SKAction.applyImpulse(velocity, duration: 0.001)
            let explosion = SKAction.run {
                if let particles = SKEmitterNode.init(fileNamed: "Explosion") {
                    particles.position = self.player.position
                    particles.zPosition = 2
                    self.addChild(particles)
                    self.player.removeFromParent()
                }
            }
            
            let gameOverBlock = SKAction.run {
                self.showGameOver()
            }
            self.player.run(SKAction.sequence([veolcityAction, SKAction.wait(forDuration: 1),explosion, gameOverBlock]))
            self.playerWashit = true
        }
        else if node.physicsBody?.categoryBitMask == PhysicsCategory.PlayerBorder && self.playerWashit {
            let playerVelocity = self.player.physicsBody?.velocity ?? CGVector.zero
            let velocity = CGVector.init(dx: playerVelocity.dx * -0.1, dy: playerVelocity.dy * -0.1)
            self.player.physicsBody?.applyImpulse(velocity)
        }
        
        
    }
    
    func showGameOver() {
        print("GameOver")
        let screenSize = UIScreen.main.bounds
        
        let gameOverText = SKLabelNode.init(fontNamed: "Helvetica")
        gameOverText.text = "Game Over"
        gameOverText.position = CGPoint.init(x: screenSize.width / 2, y: screenSize.height / 2)
        gameOverText.numberOfLines = 3
        gameOverText.alpha = 0
        gameOverText.fontSize = 40
        gameOverText.zPosition = 100
        
        let fadeInText = SKAction.fadeAlpha(by: 1.0, duration: 1)
        
        self.addChild(gameOverText)
        gameOverText.run(fadeInText)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            
            let scene = FirstScene(size:self.size)
            // 场景过渡动画
            let transition = SKTransition.crossFade(withDuration: 0.5)
            self.view?.presentScene(scene, transition: transition)
        }
    }
    
}

extension SpaceScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }

        var firstNode: SKNode
        var sencondNode: SKNode

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstNode = nodeA
            sencondNode = nodeB
        } else {
            firstNode = nodeB
            sencondNode = nodeA
        }

        guard let firstBody = firstNode.physicsBody, let secondBody = sencondNode.physicsBody else { return }

        switch (firstBody.categoryBitMask, secondBody.categoryBitMask) {
        case (PhysicsCategory.Player, PhysicsCategory.Enemy), (PhysicsCategory.Player, PhysicsCategory.PlayerBorder), (PhysicsCategory.Player, PhysicsCategory.Energy):
            self.playerHit(node: sencondNode)
        default:
            ()
        }
    }
}

