//
//  GameScene.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var grid: Grid!
    
    override func didMove(to view: SKView) {
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        grid = Grid(blockSize: 60, rows:5, cols:5)
        grid.position = CGPoint(x: view.frame.midX - grid.blockSize * CGFloat(grid.cols) / 2 - offset, y: view.frame.midY + grid.blockSize * CGFloat(grid.rows) / 2 + offset)
        addChild(grid)
        grid.anchorPoint = CGPoint(x: 0, y: 1.0)
        
        let gamePiece = SKSpriteNode(imageNamed: "Spaceship")
        gamePiece.setScale(0.0625)
        gamePiece.position = grid.gridPosition(row: 2, col: 0)
        grid.addChild(gamePiece)
    }
    
    func removeWalls() {
        grid.enumerateChildNodes(withName: "wall") { (node, pointer) in
            node.removeFromParent()
        }
    }
    
    func addWalls(game: Game) {
        for (p, n) in game.walls {
            let point = grid.gridPosition(row: p.row, col: p.col)
            let wall = SKSpriteNode(color: SKColor.white, size: CGSize(width: 56, height: 56))
            wall.position = point
            wall.name = "wall"
            grid.addChild(wall)
            guard n >= 0 else {continue}
            let lbl = SKLabelNode(text: String(n))
            lbl.fontColor = SKColor.black
            lbl.fontName = lbl.fontName! + "-Bold"
            lbl.verticalAlignmentMode = .center
            lbl.position = point
            lbl.name = "wall"
            grid.addChild(lbl)
        }
    }
    
    func didTap(_ point: CGPoint) {
        
    }
}
