//
//  SumscrapersGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class SumscrapersGameScene: GameScene<SumscrapersGameState> {
    var gridNode: SumscrapersGridNode {
        get { getGridNode() as! SumscrapersGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addNumber(n: Int, s: HintState, isHint: Bool, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: SumscrapersGameState, skView: SKView) {
        let game = game as! SumscrapersGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: SumscrapersGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Numbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let n = state[p]
                guard n != 0 else {continue}
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let numNodeName = "num" + nodeNameSuffix
                let s = state.pos2state(row: r, col: c)
                addNumber(n: n, s: s, isHint: !game.isValid(p: p), point: point, nodeName: numNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: SumscrapersGameState, to stateTo: SumscrapersGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numNodeName = "num" + nodeNameSuffix
                func removeNumber() { removeNode(withName: numNodeName) }
                let (n1, n2) = (stateFrom[r, c], stateTo[r, c])
                let (s1, s2) = (stateFrom.pos2state(row: r, col: c), stateTo.pos2state(row: r, col: c))
                guard n1 != n2 || s1 != s2 else {continue}
                if (n1 != 0) { removeNumber() }
                if (n2 != 0) { addNumber(n: n2, s: s2, isHint: !stateFrom.game.isValid(p: p), point: point, nodeName: numNodeName) }
            }
        }
    }
}
