//
//  Square100GameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class Square100GameScene: GameScene<Square100GameState> {
    var gridNode: Square100GridNode {
        get {return getGridNode() as! Square100GridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addNumber(n: String, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    func addHint(p: Position, n: Int) {
        let point = gridNode.gridPosition(p: p)
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addNumber(n: String(n), s: n == 100 ? .complete : .error, point: point, nodeName: hintNodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: Square100GameState, skView: SKView) {
        let game = game as! Square100Game
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols + 1)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: Square100GridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols + 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows + 1) / 2 + offset))
        
        // addNumbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let n = state.game[p]
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let numberNodeName = "number" + nodeNameSuffix
                addNumber(n: n, s: .normal, point: point, nodeName: numberNodeName)
            }
        }
        
        // addHints
        for r in 0..<game.rows {
            let p = Position(r, game.cols)
            let n = state.row2hint[r]
            addHint(p: p, n: n)
        }
        for c in 0..<game.cols {
            let p = Position(game.rows, c)
            let n = state.col2hint[c]
            addHint(p: p, n: n)
        }
    }
    
    override func levelUpdated(from stateFrom: Square100GameState, to stateTo: Square100GameState) {
        func removeHint(p: Position) {
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            removeNode(withName: hintNodeName)
        }
        for r in 0..<stateFrom.rows {
            let p = Position(r, stateFrom.cols)
            let n = stateTo.row2hint[r]
            if stateFrom.row2hint[r] != n {
                removeHint(p: p)
                addHint(p: p, n: n)
            }
        }
        for c in 0..<stateFrom.cols {
            let p = Position(stateFrom.rows, c)
            let n = stateTo.col2hint[c]
            if stateFrom.col2hint[c] != n {
                removeHint(p: p)
                addHint(p: p, n: n)
            }
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                let (o1, o2) = (stateFrom[r, c], stateTo[r, c])
                guard o1 != o2 else {continue}
                removeNode(withName: numberNodeName)
                addNumber(n: o2, s: .normal, point: point, nodeName: numberNodeName)
            }
        }
    }
}
