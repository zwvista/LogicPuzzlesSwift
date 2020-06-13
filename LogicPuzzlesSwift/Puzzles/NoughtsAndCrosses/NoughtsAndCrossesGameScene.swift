//
//  NoughtsAndCrossesGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class NoughtsAndCrossesGameScene: GameScene<NoughtsAndCrossesGameState> {
    var gridNode: NoughtsAndCrossesGridNode {
        get { getGridNode() as! NoughtsAndCrossesGridNode }
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

    override func levelInitialized(_ game: AnyObject, state: NoughtsAndCrossesGameState, skView: SKView) {
        let game = game as! NoughtsAndCrossesGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: NoughtsAndCrossesGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addNumbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let ch = game[p]
                let b = game.noughts.contains(p)
                guard ch != " " || b else {continue}
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                if b {
                    addCircleMarker(color: .white, point: point, nodeName: markerNodeName)
                } else {
                    addLabel(text: String(ch), fontColor: .gray, point: point, nodeName: numberNodeName)
                }
            }
        }

        // addHints
        for r in 0..<game.rows {
            let s = state.row2state[r]
            guard s != .normal else {continue}
            let c = game.cols - 1
            let p = Position(r, c)
            let point = gridNode.gridPosition(p: p)
            addHint(p: Position(r, game.cols), isHorz: true, s: s, point: point)
        }
        for c in 0..<game.cols {
            let s = state.col2state[c]
            guard s != .normal else {continue}
            let r = game.rows - 1
            let p = Position(r, c)
            let point = gridNode.gridPosition(p: p)
            addHint(p: Position(r, game.cols), isHorz: false, s: s, point: point)
        }
    }
    
    override func levelUpdated(from stateFrom: NoughtsAndCrossesGameState, to stateTo: NoughtsAndCrossesGameState) {
        func removeHint(p: Position, isHorz: Bool) {
            let nodeNameSuffix = "-\(p.row)-\(p.col)-" + (isHorz ? "h" : "v")
            let hintNodeName = "hint" + nodeNameSuffix
            removeNode(withName: hintNodeName)
        }
        for r in 0..<stateFrom.rows {
            let (s1, s2) = (stateFrom.row2state[r], stateTo.row2state[r])
            guard s1 != s2 else {continue}
            let c = stateFrom.cols - 1
            let p = Position(r, c)
            let point = gridNode.gridPosition(p: p)
            if s1 != .normal { removeHint(p: p, isHorz: true) }
            if s2 != .normal { addHint(p: p, isHorz: true, s: s2, point: point) }
        }
        for c in 0..<stateFrom.cols {
            let (s1, s2) = (stateFrom.col2state[c], stateTo.col2state[c])
            guard s1 != s2 else {continue}
            let r = stateFrom.rows - 1
            let p = Position(r, c)
            let point = gridNode.gridPosition(p: p)
            if s1 != .normal { removeHint(p: p, isHorz: false) }
            if s2 != .normal { addHint(p: p, isHorz: false, s: s2, point: point) }
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                guard stateFrom.game[p] == " " else {continue}
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                let (ch1, ch2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p] ?? .normal, stateTo.pos2state[p] ?? .normal)
                if ch1 != ch2 || s1 != s2 {
                    if ch1 != " " { removeNode(withName: numberNodeName) }
                    if ch2 != " " { addLabel(text: String(ch2), fontColor: s2 == .normal ? .white : s2 == .complete ? .green : .red, point: point, nodeName: numberNodeName) }
                }
            }
        }
    }
}
