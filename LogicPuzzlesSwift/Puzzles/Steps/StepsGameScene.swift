//
//  StepsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class StepsGameScene: GameScene<StepsGameState> {
    var gridNode: StepsGridNode {
        get { getGridNode() as! StepsGridNode }
        set { setGridNode(gridNode: newValue) }
    }

    override func levelInitialized(_ game: AnyObject, state: StepsGameState, skView: SKView) {
        let game = game as! StepsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: StepsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
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
        
        // add Numbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let n = state[p]
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                if n == StepsGame.PUZ_FORBIDDEN {
                    let forbiddenNodeName = "forbidden" + nodeNameSuffix
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                } else if n != StepsGame.PUZ_EMPTY {
                    let numberNodeName = "number" + nodeNameSuffix
                    addLabel(text: String(n), fontColor: .gray, point: point, nodeName: numberNodeName)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: StepsGameState, to stateTo: StepsGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let (n1, n2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                guard n1 != n2 || s1 != s2 else {continue}
                if n1 == StepsGame.PUZ_MARKER {
                    removeNode(withName: markerNodeName)
                } else if n1 == StepsGame.PUZ_FORBIDDEN {
                    removeNode(withName: forbiddenNodeName)
                } else if n1 != StepsGame.PUZ_EMPTY {
                    removeNode(withName: numberNodeName)
                }
                if n2 == StepsGame.PUZ_MARKER {
                    addDotMarker(point: point, nodeName: forbiddenNodeName)
                } else if n2 == StepsGame.PUZ_FORBIDDEN {
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                } else if n2 != StepsGame.PUZ_EMPTY {
                    addLabel(text: String(n2), fontColor: stateFrom.game[p] != StepsGame.PUZ_EMPTY ? .gray : s2 == .normal ? .white : s2 == .complete ? .green : .red, point: point, nodeName: numberNodeName)
                }
            }
        }
    }
}
