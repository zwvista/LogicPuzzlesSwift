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
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: MinesweeperGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addHints
        for (p, n) in game.pos2hint {
            guard case let .hint(state: s) = state[p] else {continue}
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: s, point: point, nodeName: hintNodeName)
        }
        
        // addForbidden
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                guard case .forbidden = state[p] else {continue}
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: MinesweeperGameState, to stateTo: MinesweeperGameState) {
        let markerOffset: CGFloat = 7.5
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let mineNodeName = "mine" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                func removeHint() { removeNode(withName: hintNodeName) }
                func addMine() {
                    addImage(imageNamed: "tree", color: .red, colorBlendFactor: 0.0, point: point, nodeName: mineNodeName)
                }
                func removeMine() { removeNode(withName: mineNodeName) }
                func addMarker() { addCircleMarker(color: .white, point: point, nodeName: markerNodeName) }
                func removeMarker() { removeNode(withName: markerNodeName) }
                func addForbidden() { addForbiddenMarker(point: point, nodeName: forbiddenNodeName) }
                func removeForbidden() { removeNode(withName: forbiddenNodeName) }
                let (ot1, ot2) = (stateFrom[r, c], stateTo[r, c])
                guard String(describing: ot1) != String(describing: ot2) else {continue}
                switch ot1 {
                case .forbidden:
                    removeForbidden()
                case .mine:
                    removeMine()
                case .marker:
                    removeMarker()
                case .hint:
                    removeHint()
                default:
                    break
                }
                switch ot2 {
                case .forbidden:
                    addForbidden()
                case .mine:
                    addMine()
                case .marker:
                    addMarker()
                case let .hint(s):
                    let n = stateTo.game.pos2hint[Position(r, c)]!
                    addHint(n: n, s: s, point: point, nodeName: hintNodeName)
                default:
                    break
                }
            }
        }
    }
}
