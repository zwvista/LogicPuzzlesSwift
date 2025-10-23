//
//  NumberCrossingGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class NumberCrossingGameScene: GameScene<NumberCrossingGameState> {
    var gridNode: NumberCrossingGridNode {
        get { getGridNode() as! NumberCrossingGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addNumber(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: NumberCrossingGameState, skView: SKView) {
        let game = game as! NumberCrossingGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: NumberCrossingGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Numbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let n = state[p]
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let numNodeName = "num" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                if n == NumberCrossingGame.PUZ_FORBIDDEN {
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                } else if n != NumberCrossingGame.PUZ_UNKNOWN {
                    let s = state.pos2state[p]!
                    addNumber(n: n, s: s, point: point, nodeName: numNodeName)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: NumberCrossingGameState, to stateTo: NumberCrossingGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numNodeName = "num" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let (n1, n2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                guard n1 != n2 || s1 != s2 else {continue}
                if n1 == NumberCrossingGame.PUZ_MARKER {
                    removeNode(withName: markerNodeName)
                } else if n1 == NumberCrossingGame.PUZ_FORBIDDEN {
                    removeNode(withName: forbiddenNodeName)
                } else if n1 != NumberCrossingGame.PUZ_UNKNOWN {
                    removeNode(withName: numNodeName)
                }
                if n2 == NumberCrossingGame.PUZ_MARKER {
                    addDotMarker(point: point, nodeName: markerNodeName)
                } else if n2 == NumberCrossingGame.PUZ_FORBIDDEN {
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                } else if n2 != NumberCrossingGame.PUZ_UNKNOWN {
                    addNumber(n: n2, s: s2!, point: point, nodeName: numNodeName)
                }
            }
        }
    }
}
