//
//  InbetweenSumscrapersGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class InbetweenSumscrapersGameScene: GameScene<InbetweenSumscrapersGameState> {
    var gridNode: InbetweenSumscrapersGridNode {
        get { getGridNode() as! InbetweenSumscrapersGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(p: Position, n: Int, s: HintState) {
        let point = gridNode.centerPoint(p: p)
        guard n >= 0 else {return}
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: hintNodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: InbetweenSumscrapersGameState, skView: SKView) {
        let game = game as! InbetweenSumscrapersGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols + 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: InbetweenSumscrapersGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols + 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows + 1) / 2 + offset))
        
        // add Hints
        for r in 0..<game.rows {
            let p = Position(r, game.cols)
            let n = state.game.row2hint[r]
            addHint(p: p, n: n, s: state.row2state[r])
        }
        for c in 0..<game.cols {
            let p = Position(game.rows, c)
            let n = state.game.col2hint[c]
            addHint(p: p, n: n, s: state.col2state[c])
        }
    }
    
    override func levelUpdated(from stateFrom: InbetweenSumscrapersGameState, to stateTo: InbetweenSumscrapersGameState) {
        func removeHint(p: Position) {
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            removeNode(withName: hintNodeName)
        }
        for r in 0..<stateFrom.rows {
            let p = Position(r, stateFrom.cols)
            let n = stateFrom.game.row2hint[r]
            if stateFrom.row2state[r] != stateTo.row2state[r] {
                removeHint(p: p)
                addHint(p: p, n: n, s: stateTo.row2state[r])
            }
        }
        for c in 0..<stateFrom.cols {
            let p = Position(stateFrom.rows, c)
            let n = stateFrom.game.col2hint[c]
            if stateFrom.col2state[c] != stateTo.col2state[c] {
                removeHint(p: p)
                addHint(p: p, n: n, s: stateTo.col2state[c])
            }
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                let skyscraperNodeName = "skyscraper" + nodeNameSuffix
                let (n1, n2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                guard n1 != n2 || s1 != s2 else {continue}
                if n1 == InbetweenSumscrapersGame.PUZ_SKYSCRAPER {
                    removeNode(withName: skyscraperNodeName)
                } else if n1 != InbetweenSumscrapersGame.PUZ_EMPTY {
                    removeNode(withName: numberNodeName)
                }
                if n2 == InbetweenSumscrapersGame.PUZ_SKYSCRAPER {
                    addImage(imageNamed: "office_building", color: .red, colorBlendFactor: s2 == .normal ? 0.0 : 0.5, point: point, nodeName: skyscraperNodeName)
                } else if n2 != InbetweenSumscrapersGame.PUZ_EMPTY {
                    addLabel(text: String(n2), fontColor: s2 == .normal ? .white : .red, point: point, nodeName: numberNodeName)
                }
            }
        }
    }
}
