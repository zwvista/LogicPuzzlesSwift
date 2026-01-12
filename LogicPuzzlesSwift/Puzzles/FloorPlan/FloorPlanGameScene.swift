//
//  FloorPlanGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class FloorPlanGameScene: GameScene<FloorPlanGameState> {
    var gridNode: FloorPlanGridNode {
        get { getGridNode() as! FloorPlanGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addNumber(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: FloorPlanGameState, skView: SKView) {
        let game = game as! FloorPlanGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: FloorPlanGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Number
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let n = state[p]
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let numberNodeName = "number" + nodeNameSuffix
                if n == FloorPlanGame.PUZ_FORBIDDEN {
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                } else if n > 0 {
                    addCircleMarker(color: .white, point: point, nodeName: "circle")
                    addNumber(n: n, s: state.pos2state[p]!, point: point, nodeName: numberNodeName)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: FloorPlanGameState, to stateTo: FloorPlanGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let numberNodeName = "number" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let (n1, n2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                guard n1 != n2 || s1 != s2 else {continue}
                if n1 == FloorPlanGame.PUZ_FORBIDDEN {
                    removeNode(withName: forbiddenNodeName)
                } else if n1 == FloorPlanGame.PUZ_MARKER {
                    removeNode(withName: markerNodeName)
                } else if n1 > 0 {
                    removeNode(withName: numberNodeName)
                }
                if n2 == FloorPlanGame.PUZ_FORBIDDEN {
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                } else if n2 == FloorPlanGame.PUZ_MARKER {
                    addDotMarker(point: point, nodeName: markerNodeName)
                } else if n2 > 0 {
                    addNumber(n: n2, s: s2!, point: point, nodeName: numberNodeName)
                }
            }
        }
    }
}
