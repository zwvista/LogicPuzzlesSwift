//
//  RobotCrosswordsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class RobotCrosswordsGameScene: GameScene<RobotCrosswordsGameState> {
    var gridNode: RobotCrosswordsGridNode {
        get {return getGridNode() as! RobotCrosswordsGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addHint(p: Position, isHorz: Bool, s: HintState) {
        var point = gridNode.gridPosition(p: p)
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
        hintNode.strokeColor = s == .normal ? .white : s == .complete ? .green : .red
        hintNode.glowWidth = 4.0
        gridNode.addChild(hintNode)
    }

    override func levelInitialized(_ game: AnyObject, state: RobotCrosswordsGameState, skView: SKView) {
        let game = game as! RobotCrosswordsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: RobotCrosswordsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addHint
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                for i in 0..<2 {
                    guard i == 0 && c != game.cols - 1 || i == 1 && r != game.rows - 1 else {continue}
                    addHint(p: Position(r, c), isHorz: i == 0, s: .normal)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: RobotCrosswordsGameState, to stateTo: RobotCrosswordsGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                let (n1, n2) = (stateFrom[r, c], stateTo[r, c])
                if n1 != n2 {
                    if n1 != 0 {removeNode(withName: numberNodeName)}
                    if n2 != 0 {addLabel(text: String(n2), fontColor: .white, point: point, nodeName: numberNodeName)}
                }
                for i in 0..<2 {
                    guard i == 0 && c != stateFrom.game.cols - 1 || i == 1 && r != stateFrom.game.rows - 1 else {continue}
                    let nodeNameSuffix = "-\(p.row)-\(p.col)-" + (i == 0 ? "h" : "v")
                    let hintNodeName = "hint" + nodeNameSuffix
                    let (s1, s2) = ((i == 0 ? stateFrom.pos2horzState : stateFrom.pos2vertState)[p] ?? .normal, (i == 0 ? stateTo.pos2horzState : stateTo.pos2vertState)[p] ?? .normal)
                    if s1 != s2 {
                        removeNode(withName: hintNodeName)
                        addHint(p: Position(r, c), isHorz: i == 0, s: s2)
                    }
                }
            }
        }
    }
}
