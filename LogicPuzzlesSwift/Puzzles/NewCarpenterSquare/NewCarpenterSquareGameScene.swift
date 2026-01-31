//
//  NewCarpenterSquareGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class NewCarpenterSquareGameScene: GameScene<NewCarpenterSquareGameState> {
    var gridNode: NewCarpenterSquareGridNode {
        get { getGridNode() as! NewCarpenterSquareGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(text: String, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: text, fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: NewCarpenterSquareGameState, skView: SKView) {
        let game = game as! NewCarpenterSquareGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: NewCarpenterSquareGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset))
        
        // add Hints
        for (p, h) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            let s = state.pos2state[p]!
            switch h {
            case .equal:
                addHint(text: "=", s: s, point: point, nodeName: hintNodeName)
            case .notEqual:
                addHint(text: "/", s: s, point: point, nodeName: hintNodeName)
            case .unknown:
                addHint(text: "?", s: s, point: point, nodeName: hintNodeName)
            }
        }
        
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                if game[r, c][1] == .line { addHorzLine(objType: .line, color: .white, point: point, nodeName: "line") }
                if game[r, c][2] == .line { addVertLine(objType: .line, color: .white, point: point, nodeName: "line") }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: NewCarpenterSquareGameState, to stateTo: NewCarpenterSquareGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let horzLineNodeName = "horzLine" + nodeNameSuffix
                let vertlineNodeName = "vertline" + nodeNameSuffix
                var (o1, o2) = (stateFrom[p][1], stateTo[p][1])
                if o1 != o2 {
                    if o1 != .empty { removeNode(withName: horzLineNodeName) }
                    addHorzLine(objType: o2, color: .yellow, point: point, nodeName: horzLineNodeName)
                }
                (o1, o2) = (stateFrom[p][2], stateTo[p][2])
                if o1 != o2 {
                    if o1 != .empty { removeNode(withName: vertlineNodeName) }
                    addVertLine(objType: o2, color: .yellow, point: point, nodeName: vertlineNodeName)
                }
            }
        }
        for (p, h) in stateFrom.game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            let (s1, s2) = (stateFrom.pos2state[p]!, stateTo.pos2state[p]!)
            guard s1 != s2 else {continue}
            removeNode(withName: hintNodeName)
            switch h {
            case .equal:
                addHint(text: "=", s: s2, point: point, nodeName: hintNodeName)
            case .notEqual:
                addHint(text: "/", s: s2, point: point, nodeName: hintNodeName)
            case .unknown:
                addHint(text: "?", s: s2, point: point, nodeName: hintNodeName)
            }
        }
    }
}
