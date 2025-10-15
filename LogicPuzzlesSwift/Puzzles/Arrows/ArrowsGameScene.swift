//
//  ArrowsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class ArrowsGameScene: GameScene<ArrowsGameState> {
    var gridNode: ArrowsGridNode {
        get { getGridNode() as! ArrowsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(p: Position, n: Int, s: HintState) {
        let point = gridNode.gridPosition(p: p)
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: hintNodeName)
    }
    
    func addArrow(n: Int, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        addImage(imageNamed: getArrowImageName(n: n), color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: ArrowsGameState, skView: SKView) {
        let game = game as! ArrowsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: ArrowsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for r in 1..<game.rows - 1 {
            for c in 1..<game.cols - 1 {
                let p = Position(r, c)
                let n = state[p]
                addHint(p: p, n: n, s: .normal)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: ArrowsGameState, to stateTo: ArrowsGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                if stateFrom.game.isCorner(p: p) {continue}
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let hintNodeName = "hint" + nodeNameSuffix
                let arrowNodeName = "arrow" + nodeNameSuffix
                if stateFrom.game.isBorder(p: p) {
                    let (n1, n2) = (stateFrom[p], stateTo[p])
                    let (s1, s2) = (stateFrom.arrow2state[p]!, stateTo.arrow2state[p]!)
                    if n1 != n2 || s1 != s2 {
                        if n1 != ArrowsGame.PUZ_UNKNOWN { removeNode(withName: arrowNodeName) }
                        if n2 != ArrowsGame.PUZ_UNKNOWN { addArrow(n: n2, s: s2, point: point, nodeName: arrowNodeName) }
                    }
                } else {
                    let (s1, s2) = (stateFrom.hint2state[p]!, stateTo.hint2state[p]!)
                    if s1 != s2 {
                        removeNode(withName: hintNodeName)
                        addHint(p: p, n: stateTo[p], s: s2)
                    }
                }
            }
        }
    }
}
