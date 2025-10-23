//
//  NumberCrosswordsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class NumberCrosswordsGameScene: GameScene<NumberCrosswordsGameState> {
    var gridNode: NumberCrosswordsGridNode {
        get { getGridNode() as! NumberCrosswordsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addNumber(n: String, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: n, fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    func addHint(p: Position, n: Int, s: HintState) {
        let point = gridNode.gridPoint(p: p)
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addNumber(n: String(n), s: s, point: point, nodeName: hintNodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: NumberCrosswordsGameState, skView: SKView) {
        let game = game as! NumberCrosswordsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: NumberCrosswordsGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addNumbers
        for r in 0..<game.rows - 1 {
            for c in 0..<game.cols - 1 {
                let p = Position(r, c)
                let point = gridNode.gridPoint(p: p)
                let n = state.game[p]
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let numberNodeName = "number" + nodeNameSuffix
                addNumber(n: String(n), s: .normal, point: point, nodeName: numberNodeName)
            }
        }
        
        // addHints
        for r in 0..<game.rows - 1 {
            let p = Position(r, game.cols - 1)
            let s = state.row2state[r]
            addHint(p: p, n: game[r, game.cols - 1], s: s)
        }
        for c in 0..<game.cols - 1 {
            let p = Position(game.rows - 1, c)
            let s = state.col2state[c]
            addHint(p: p, n: game[game.rows - 1, c], s: s)
        }
    }
    
    override func levelUpdated(from stateFrom: NumberCrosswordsGameState, to stateTo: NumberCrosswordsGameState) {
        func removeHint(p: Position) {
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            removeNode(withName: hintNodeName)
        }
        for r in 0..<stateFrom.rows - 1 {
            let p = Position(r, stateFrom.cols - 1)
            let s = stateTo.row2state[r]
            if stateFrom.row2state[r] != s {
                removeHint(p: p)
                addHint(p: p, n: stateFrom.game[r, stateFrom.cols - 1], s: s)
            }
        }
        for c in 0..<stateFrom.cols - 1 {
            let p = Position(stateFrom.rows - 1, c)
            let s = stateTo.col2state[c]
            if stateFrom.col2state[c] != s {
                removeHint(p: p)
                addHint(p: p, n: stateFrom.game[stateFrom.rows - 1, c], s: s)
            }
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                let darkenNodeName = "darken" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                func addNumber2() { addNumber(n: String(stateFrom.game[p]), s: .normal, point: point, nodeName: numberNodeName) }
                func removeNumber() { removeNode(withName: numberNodeName) }
                func addDarken() {
                    let darkenNode = SKSpriteNode(color: .lightGray, size: coloredRectSize())
                    darkenNode.position = point
                    darkenNode.name = darkenNodeName
                    gridNode.addChild(darkenNode)
                }
                func removeDarken() { removeNode(withName: darkenNodeName) }
                func addMarker() { addCircleMarker(color: .white, point: point, nodeName: markerNodeName) }
                func removeMarker() { removeNode(withName: markerNodeName) }
                let (o1, o2) = (stateFrom[r, c], stateTo[r, c])
                guard o1 != o2 else {continue}
                switch o1 {
                case .darken:
                    removeDarken()
                case .marker:
                    removeMarker()
                default:
                    break
                }
                switch o2 {
                case .darken:
                    removeNumber()
                    addDarken()
                    addNumber2()
                case .marker:
                    addMarker()
                default:
                    break
                }                
            }
        }
    }
}
