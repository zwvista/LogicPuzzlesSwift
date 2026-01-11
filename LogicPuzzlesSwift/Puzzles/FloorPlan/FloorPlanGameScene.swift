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
    
    func addHint(p: Position, isHorz: Bool, s: HintState, point: CGPoint) {
        var point = point
        if isHorz {
            point.x += gridNode.blockSize / 2
        } else {
            point.y -= gridNode.blockSize / 2
        }
        let nodeNameSuffix = "-\(p.row)-\(p.col)-" + (isHorz ? "h" : "v")
        let nodeName = "hint" + nodeNameSuffix
        let hintNode = SKShapeNode(circleOfRadius: gridNode.blockSize / 8)
        hintNode.position = point
        hintNode.name = nodeName
        hintNode.strokeColor = s == .complete ? .green : .red
        hintNode.fillColor = s == .complete ? .green : .red
        hintNode.glowWidth = 4.0
        gridNode.addChild(hintNode)
    }

    override func levelInitialized(_ game: AnyObject, state: FloorPlanGameState, skView: SKView) {
        let game = game as! FloorPlanGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: FloorPlanGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addSquare addHint
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let n = game[p]
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                if n == -1 {
                    let squareNode = SKSpriteNode(color: .white, size: coloredRectSize())
                    squareNode.position = point
                    squareNode.name = "square"
                    gridNode.addChild(squareNode)
                } else if n > 0 {
                    addLabel(text: String(n), fontColor: .gray, point: point, nodeName: numberNodeName)
                    for i in 0..<2 {
                        let s: HintState = i == 0 ? state.pos2horzState[p] ?? .normal : state.pos2vertState[p] ?? .normal
                        if s != .normal { addHint(p: Position(r, c), isHorz: i == 0, s: s, point: point) }
                    }
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
                let numberNodeName = "number" + nodeNameSuffix
                let (n1, n2) = (stateFrom[r, c], stateTo[r, c])
                if stateFrom.game[p] == 0 && n1 != n2 {
                    if n1 != 0 { removeNode(withName: numberNodeName) }
                    if n2 != 0 { addLabel(text: String(n2), fontColor: .white, point: point, nodeName: numberNodeName) }
                }
                for i in 0..<2 {
                    let nodeNameSuffix = "-\(p.row)-\(p.col)-" + (i == 0 ? "h" : "v")
                    let hintNodeName = "hint" + nodeNameSuffix
                    let (s1, s2) = ((i == 0 ? stateFrom.pos2horzState : stateFrom.pos2vertState)[p] ?? .normal, (i == 0 ? stateTo.pos2horzState : stateTo.pos2vertState)[p] ?? .normal)
                    if s1 != .normal { removeNode(withName: hintNodeName) }
                    if s2 != .normal { addHint(p: Position(r, c), isHorz: i == 0, s: s2, point: point) }
                }
            }
        }
    }
}
