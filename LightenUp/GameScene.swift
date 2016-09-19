//
//  GameScene.swift
//  LightenUp
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var gridNode: GridNode!
    
    func coloredRectSize() -> CGSize {
        let sz = gridNode.blockSize - 4
        return CGSize(width: sz, height: sz)
    }
    
    func addGrid(to view: SKView, rows: Int, cols: Int, blockSize: CGFloat) {
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        gridNode = GridNode(blockSize: blockSize, rows: rows, cols: cols)
        gridNode.position = CGPoint(x: view.frame.midX - gridNode.blockSize * CGFloat(gridNode.cols) / 2 - offset, y: view.frame.midY + gridNode.blockSize * CGFloat(gridNode.rows) / 2 + offset)
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
    }
    
    func addWalls(from game: Game) {
        for (p, n) in game.walls {
            let point = gridNode.gridPosition(p: p)
            let wallNode = SKSpriteNode(color: SKColor.white, size: coloredRectSize())
            wallNode.position = point
            wallNode.name = "wall"
            gridNode.addChild(wallNode)
            guard n >= 0 else {continue}
            let numberNode = SKLabelNode(text: String(n))
            numberNode.fontColor = SKColor.black
            numberNode.fontName = numberNode.fontName! + "-Bold"
            numberNode.fontSize *= CGFloat(gridNode.blockSize) / 60.0
            numberNode.verticalAlignmentMode = .center
            numberNode.position = point
            numberNode.name = "wall"
            gridNode.addChild(numberNode)
        }
    }
    
    func process(move: GameMove) {
        func lightCellNodeName(p: Position) -> String {
            return "lightCell-\(p.row)-\(p.col)"
        }
        func lightbulbNodeName(p: Position) -> String {
            return "lightbulb-\(p.row)-\(p.col)"
        }
        if move.toadd {
            for p in move.lightCells {
                let point = gridNode.gridPosition(p: p)
                let lightCellNode = SKSpriteNode(color: SKColor.yellow, size: coloredRectSize())
                lightCellNode.position = point
                lightCellNode.name = lightCellNodeName(p: p)
                gridNode.addChild(lightCellNode)
            }
            for p in move.lightbulbs {
                let lightbulbNode = SKSpriteNode(imageNamed: "lightbulb")
                lightbulbNode.setScale(CGFloat(gridNode.blockSize) / 300.0)
                lightbulbNode.position = gridNode.gridPosition(p: p)
                lightbulbNode.name = lightbulbNodeName(p: p)
                gridNode.addChild(lightbulbNode)
            }
        } else {
            for p in move.lightCells {
                gridNode.enumerateChildNodes(withName: lightCellNodeName(p: p)) { (node, pointer) in
                    node.removeFromParent()
                }
            }
            for p in move.lightbulbs {
                gridNode.enumerateChildNodes(withName: lightbulbNodeName(p: p)) { (node, pointer) in
                    node.removeFromParent()
                }
            }
        }
    }
}
