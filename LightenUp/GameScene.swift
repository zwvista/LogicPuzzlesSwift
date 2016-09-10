//
//  GameScene.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        scaleMode = .ResizeFill
        let grid = Grid(blockSize: 60.0, rows:5, cols:5)
        grid.position = CGPointMake (CGRectGetMidX(view.frame),CGRectGetMidY(view.frame))
        addChild(grid)
        
        let gamePiece = SKSpriteNode(imageNamed: "Spaceship")
        gamePiece.setScale(0.0625)
        gamePiece.position = grid.gridPosition(1, col: 0)
        grid.addChild(gamePiece)
    }
}