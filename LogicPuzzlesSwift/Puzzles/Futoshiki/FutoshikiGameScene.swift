//
//  FutoshikiGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class FutoshikiGameScene: GameScene<FutoshikiGameState> {
    var gridNode: FutoshikiGridNode {
        get {return getGridNode() as! FutoshikiGridNode}
        set {setGridNode(gridNode: newValue)}
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
    
    func addHint2(ch: Character, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(ch), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: FutoshikiGameState, skView: SKView) {
        let game = game as! FutoshikiGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: FutoshikiGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
                
        for r in stride(from: 0, to: game.rows, by: 2) {
            for c in stride(from: 0, to: game.cols, by: 2) {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                let ch = state[p]
                if ch != " " {addLabel(text: String(ch), fontColor: .white, point: point, nodeName: numberNodeName)}
                let cellNode = SKShapeNode(rectOf: CGSize(width: blockSize, height: blockSize))
                cellNode.position = point
                gridNode.addChild(cellNode)
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
        for (p, h) in game.pos2hint {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hint2NodeName = "hint2" + nodeNameSuffix
            addHint2(ch: h, s: state.pos2state[p]!, point: point, nodeName: hint2NodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: FutoshikiGameState, to stateTo: FutoshikiGameState) {
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
            if s1 != .normal {removeHint(p: p, isHorz: true)}
            if s2 != .normal {addHint(p: p, isHorz: true, s: s2, point: point)}
        }
        for c in 0..<stateFrom.cols {
            let (s1, s2) = (stateFrom.col2state[c], stateTo.col2state[c])
            guard s1 != s2 else {continue}
            let r = stateFrom.rows - 1
            let p = Position(r, c)
            let point = gridNode.gridPosition(p: p)
            if s1 != .normal {removeHint(p: p, isHorz: false)}
            if s2 != .normal {addHint(p: p, isHorz: false, s: s2, point: point)}
        }
        for r in stride(from: 0, to: stateFrom.rows, by: 2) {
            for c in stride(from: 0, to: stateFrom.cols, by: 2) {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                let (ch1, ch2) = (stateFrom[p], stateTo[p])
                if ch1 != ch2 {
                    if ch1 != " " {removeNode(withName: numberNodeName)}
                    if ch2 != " " {addLabel(text: String(ch2), fontColor: .white, point: point, nodeName: numberNodeName)}
                }
            }
        }
        for (p, h) in stateFrom.game.pos2hint {
            let (s1, s2) = (stateFrom.pos2state[p]!, stateTo.pos2state[p]!)
            guard s1 != s2 else {continue}
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hint2NodeName = "hint2" + nodeNameSuffix
            removeNode(withName: hint2NodeName)
            addHint2(ch: h, s: s2, point: point, nodeName: hint2NodeName)
        }
    }
}
