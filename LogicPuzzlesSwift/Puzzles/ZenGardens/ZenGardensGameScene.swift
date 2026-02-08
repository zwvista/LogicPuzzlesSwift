//
//  ZenGardensGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class ZenGardensGameScene: GameScene<ZenGardensGameState> {
    var gridNode: ZenGardensGridNode {
        get { getGridNode() as! ZenGardensGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addTile(o: ZenGardensObject, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        addImage(imageNamed: o == .empty ? "C2" : o == .stone ? "C3" : "C4", color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName)
    }
    
    func addLine(game: ZenGardensGame) {
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path: pathToDraw)
        for r in 0..<game.rows + 1 {
            for c in 0..<game.cols + 1 {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                for dir in 1...2 {
                    guard game.dots[r, c][dir] == .line else {continue}
                    switch dir {
                    case 1:
                        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        pathToDraw.addLine(to: CGPoint(x: point.x + gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        lineNode.glowWidth = 8
                    case 2:
                        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        pathToDraw.addLine(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y - gridNode.blockSize / 2))
                        lineNode.glowWidth = 8
                    default:
                        break
                    }
                }
            }
        }
        lineNode.path = pathToDraw
        lineNode.name = "line"
        gridNode.addChild(lineNode)
    }
    
    override func levelInitialized(_ game: AnyObject, state: ZenGardensGameState, skView: SKView) {
        let game = game as! ZenGardensGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: ZenGardensGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                addTile(o: game[p], s: state.pos2state[p]!, point: point, nodeName: tileNodeName)
            }
        }
        
        addLine(game: game)
    }
    
    override func levelUpdated(from stateFrom: ZenGardensGameState, to stateTo: ZenGardensGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p]!, stateTo.pos2state[p]!)
                guard o1 != o2 || s1 != s2 else {continue}
                removeNode(withName: tileNodeName)
                addTile(o: o2, s: s2, point: point, nodeName: tileNodeName)
            }
        }

        removeNode(withName: "line")
        addLine(game: stateFrom.game)
    }
}
