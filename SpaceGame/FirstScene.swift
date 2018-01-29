//
//  FirstScene.swift
//  SpaceGame
//
//  Created by 韩小胜 on 2018/1/22.
//  Copyright © 2018年 sun. All rights reserved.
//

import UIKit
import SpriteKit

class FirstScene: SKScene {
    override func didMove(to view: SKView) {
        creatScene()
    }
    
    func creatScene() {
        self.backgroundColor = SKColor.gray
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.name = "label"
        myLabel.text = "Game"
        myLabel.fontSize = 28
        myLabel.position = CGPoint(x:self.frame.midX,y:self.frame.midY)
        self.addChild(myLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let labelNode = self.childNode(withName: "label")
        let moveUp = SKAction.moveBy(x: 0, y: 100, duration: 0.5)
        // 放大动作
        let zoom = SKAction.scale(to: 2.0, duration: 0.25)
        // 暂停动作
        let pause = SKAction.wait(forDuration: 0.5)
        // 淡出动作
        let fadeAway = SKAction.fadeOut(withDuration: 0.25)
        // 从父对象移除
        let remove = SKAction.removeFromParent()
        // 动作序列
        let moveSequence = SKAction.sequence([moveUp,zoom,pause,fadeAway,remove])
        
        labelNode?.run(moveSequence, completion: {
            let scene = SpaceScene(size:self.size)
            // 场景过渡动画
            let transition = SKTransition.crossFade(withDuration: 0.5)
            self.view?.presentScene(scene, transition: transition)
        })  
        
    }
    
    
    
}
