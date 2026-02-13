//
//  MirrorsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class MirrorsGameScene: GameScene<MirrorsGameState> {
    var gridNode: MirrorsGridNode {
        get { getGridNode() as! MirrorsGridNode }
        set { setGridNode(gridNode: newValue) }
    }

    func addLine(dir: Int, color: SKColor, point: CGPoint, nodeName: String) {
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path:pathToDraw)
        lineNode.glowWidth = 8
        switch dir {
        case 0:
            pathToDraw.move(to: CGPoint(x: point.x, y: point.y))
            pathToDraw.addLine(to: CGPoint(x: point.x, y: point.y + gridNode.blockSize / 2))
        case 1:
            pathToDraw.move(to: CGPoint(x: point.x, y: point.y))
            pathToDraw.addLine(to: CGPoint(x: point.x + gridNode.blockSize / 2, y: point.y))
        case 2:
            pathToDraw.move(to: CGPoint(x: point.x, y: point.y))
            pathToDraw.addLine(to: CGPoint(x: point.x, y: point.y - gridNode.blockSize / 2))
        case 3:
            pathToDraw.move(to: CGPoint(x: point.x, y: point.y))
            pathToDraw.addLine(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y))
        default:
            break
        }
        lineNode.path = pathToDraw
        lineNode.strokeColor = color
        lineNode.name = nodeName
        gridNode.addChild(lineNode)
    }

    override func levelInitialized(_ game: AnyObject, state: MirrorsGameState, skView: SKView) {
        let game = game as! MirrorsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: MirrorsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Numbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                switch state[p] {
                case .block:
                    let blockNode = SKSpriteNode(color: .lightGray, size: coloredRectSize())
                    blockNode.position = point
                    blockNode.name = "block"
                    gridNode.addChild(blockNode)
                case .empty: break
                default:
                    for dir in state.pos2dirs[p]! {
                        addLine(dir: dir, color: .white, point: point, nodeName: "line")
                    }
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: MirrorsGameState, to stateTo: MirrorsGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let (dirs1, dirs2) = (stateFrom.pos2dirs[p]!, stateTo.pos2dirs[p]!)
                for dir in 0..<4 {
                    let nodeNameSuffix = "-\(r)-\(c)-\(dir)"
                    let lineNodeName = "line" + nodeNameSuffix
                    func removeLine() { removeNode(withName: lineNodeName) }
                    let (b1, b2) = (dirs1.contains(dir), dirs2.contains(dir))
                    guard b1 != b2 else {continue}
                    if b1 { removeLine() }
                    if b2 { addLine(dir: dir, color: .green, point: point, nodeName: lineNodeName) }
                 }
            }
        }
    }
}
