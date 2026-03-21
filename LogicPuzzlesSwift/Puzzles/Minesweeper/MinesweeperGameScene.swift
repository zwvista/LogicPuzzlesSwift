//
//  MinesweeperGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class MinesweeperGameScene: GameScene<MinesweeperGameState> {
    var gridNode: MinesweeperGridNode {
        get { getGridNode() as! MinesweeperGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: MinesweeperGameState, skView: SKView) {
        let game = game as! MinesweeperGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: MinesweeperGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            let s = state.pos2state[p]!
            addHint(n: n, s: s, point: point, nodeName: hintNodeName)
        }
        
        // addForbidden
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                guard state[p] == .forbidden else {continue}
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: MinesweeperGameState, to stateTo: MinesweeperGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let mineNodeName = "mine" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                guard o1 != o2 || s1 != s2 else {continue}
                switch o1 {
                case .forbidden:
                    removeNode(withName: forbiddenNodeName)
                case .mine:
                    removeNode(withName: mineNodeName)
                case .marker:
                    removeNode(withName: markerNodeName)
                case .hint:
                    removeNode(withName: hintNodeName)
                default:
                    break
                }
                switch o2 {
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                case .mine:
                    addImage(imageNamed: "bomb", color: .red, colorBlendFactor: 0.0, point: point, nodeName: mineNodeName)
                case .marker:
                    addCircleMarker(color: .white, point: point, nodeName: markerNodeName)
                case .hint:
                    let n = stateTo.game.pos2hint[p]!
                    addHint(n: n, s: s2!, point: point, nodeName: hintNodeName)
                default:
                    break
                }
            }
        }
    }
}
