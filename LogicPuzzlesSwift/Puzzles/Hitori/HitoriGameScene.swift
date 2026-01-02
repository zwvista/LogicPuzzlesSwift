//
//  HitoriGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class HitoriGameScene: GameScene<HitoriGameState> {
    var gridNode: HitoriGridNode {
        get { getGridNode() as! HitoriGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addNumber(n: String, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: n, fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    func addHint(p: Position, n: String) {
        let point = gridNode.centerPoint(p: p)
        guard !n.isEmpty else {return}
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addNumber(n: n, s: .error, point: point, nodeName: hintNodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: HitoriGameState, skView: SKView) {
        let game = game as! HitoriGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols + 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: HitoriGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols + 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows + 1) / 2 + offset))
        
        // addNumbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let n = state.game[p]
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let numberNodeName = "number" + nodeNameSuffix
                addNumber(n: String(n), s: .normal, point: point, nodeName: numberNodeName)
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
    
    override func levelUpdated(from stateFrom: HitoriGameState, to stateTo: HitoriGameState) {
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
                let point = gridNode.centerPoint(p: p)
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
