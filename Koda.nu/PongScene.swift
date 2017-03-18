//
//  PongScene.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 16/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import SpriteKit

class PongScene: SKScene {
    
    let player = SKSpriteNode(imageNamed: "like")
    
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        addChild(player)
        
    }
}
