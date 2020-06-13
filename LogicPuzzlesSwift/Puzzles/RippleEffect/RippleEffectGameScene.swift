//
//  RippleEffectGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class RippleEffectGameScene: GameScene<RippleEffectGameState> {
    var gridNode: RippleEffectGridNode {
        get { getGridNode() as! RippleEffectGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addNumber(n: Int, s: HintState, isFixed: Bool, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: isFixed ? .gray : s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: RippleEffectGameState, skView: SKView) {
        let game = game as! RippleEffectGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: RippleEffectGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path: pathToDraw)
        for r in 0..<game.rows + 1 {
            for c in 0..<game.cols + 1 {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
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
        
        // add Characters
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let n = game[p]
                guard n != 0 else {continue}
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let numberNodeName = "number" + nodeNameSuffix
                addNumber(n: n, s: state.pos2state[p] ?? .normal, isFixed: game[p] != 0, point: point, nodeName: numberNodeName)
            }
        }

    }
    
    override func levelUpdated(from stateFrom: RippleEffectGameState, to stateTo: RippleEffectGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                let (n1, n2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                if n1 != n2 || s1 != s2 {
                    if (n1 != 0) {
                        removeNode(withName: numberNodeName)
                    }
                    if (n2 != 0) {
                        addNumber(n: n2, s: stateTo.pos2state[p] ?? .normal, isFixed: stateTo.game[p] != 0, point: point, nodeName: numberNodeName)
                    }
                }
            }
        }
    }
}
