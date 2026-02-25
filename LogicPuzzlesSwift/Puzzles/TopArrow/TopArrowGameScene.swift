//
//  TopArrowGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class TopArrowGameScene: GameScene<TopArrowGameState> {
    var gridNode: TopArrowGridNode {
        get { getGridNode() as! TopArrowGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(d: Int, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        let imageName = switch d {
        case 0: "arrow_green_up"
        case 1: "arrow_green_right"
        case 2: "arrow_green_down"
        default: "arrow_green_left"
        }
        addImage(imageNamed: imageName, color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: TopArrowGameState, skView: SKView) {
        let game = game as! TopArrowGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: TopArrowGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
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
        
        // add Characters
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let numberNodeName = "number" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let n = game[p]
                if n == TopArrowGame.PUZ_BLOCK {
                    addBlock(color: .darkGray, point: point, nodeName: "block")
                } else if n == TopArrowGame.PUZ_HINT {
                    addHint(d: game.pos2hint[p]!, s: state.pos2state[p]!, point: point, nodeName: hintNodeName)
                } else if n != TopArrowGame.PUZ_EMPTY {
                    addLabel(text: String(n), fontColor: .gray, point: point, nodeName: numberNodeName)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: TopArrowGameState, to stateTo: TopArrowGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let (n1, n2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                guard n1 != n2 || s1 != s2 else {continue}
                if n1 == TopArrowGame.PUZ_HINT {
                    removeNode(withName: hintNodeName)
                } else if n1 != TopArrowGame.PUZ_EMPTY {
                    removeNode(withName: numberNodeName)
                }
                if n2 == TopArrowGame.PUZ_HINT {
                    addHint(d: stateFrom.game.pos2hint[p]!, s: s2!, point: point, nodeName: hintNodeName)
                } else if n2 != TopArrowGame.PUZ_EMPTY {
                    addLabel(text: String(n2), fontColor: stateFrom.game[p] != TopArrowGame.PUZ_EMPTY ? .gray : s2 == .normal ? .white : .red, point: point, nodeName: numberNodeName)
                }
            }
        }
    }
}
