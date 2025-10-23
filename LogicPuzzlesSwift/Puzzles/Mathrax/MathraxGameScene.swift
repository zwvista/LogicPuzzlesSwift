//
//  MathraxGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class MathraxGameScene: GameScene<MathraxGameState> {
    var gridNode: MathraxGridNode {
        get { getGridNode() as! MathraxGridNode }
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
    
    func addMath(h: MathraxHint, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: h.description(), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName, size: CGSize(width: gridNode.blockSize / 2, height: gridNode.blockSize / 2))
    }

    override func levelInitialized(_ game: AnyObject, state: MathraxGameState, skView: SKView) {
        let game = game as! MathraxGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: MathraxGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
                
        // addNumbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let n = game[p]
                guard n != 0 else {continue}
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                addLabel(text: String(n), fontColor: .gray, point: point, nodeName: numberNodeName)
            }
        }
        
        // addHints
        for r in 0..<game.rows {
            let s = state.row2state[r]
            guard s != .normal else {continue}
            let c = game.cols - 1
            let p = Position(r, c)
            let point = gridNode.centerPoint(p: p)
            addHint(p: Position(r, game.cols), isHorz: true, s: s, point: point)
        }
        for c in 0..<game.cols {
            let s = state.col2state[c]
            guard s != .normal else {continue}
            let r = game.rows - 1
            let p = Position(r, c)
            let point = gridNode.centerPoint(p: p)
            addHint(p: Position(r, game.cols), isHorz: false, s: s, point: point)
        }
        for (p, h) in game.pos2hint {
            var point = gridNode.centerPoint(p: p)
            point.x += blockSize / 2; point.y -= blockSize / 2
            let markerNode = SKShapeNode(circleOfRadius: blockSize / 4)
            markerNode.position = point
            markerNode.name = "marker"
            markerNode.strokeColor = .yellow
            markerNode.fillColor = .black
            markerNode.glowWidth = 1.0
            gridNode.addChild(markerNode)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let mathNodeName = "math" + nodeNameSuffix
            addMath(h: h, s: state.pos2state[p]!, point: point, nodeName: mathNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: MathraxGameState, to stateTo: MathraxGameState) {
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
            let point = gridNode.centerPoint(p: p)
            if s1 != .normal { removeHint(p: p, isHorz: true) }
            if s2 != .normal { addHint(p: p, isHorz: true, s: s2, point: point) }
        }
        for c in 0..<stateFrom.cols {
            let (s1, s2) = (stateFrom.col2state[c], stateTo.col2state[c])
            guard s1 != s2 else {continue}
            let r = stateFrom.rows - 1
            let p = Position(r, c)
            let point = gridNode.centerPoint(p: p)
            if s1 != .normal { removeHint(p: p, isHorz: false) }
            if s2 != .normal { addHint(p: p, isHorz: false, s: s2, point: point) }
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                let (n1, n2) = (stateFrom[p], stateTo[p])
                if n1 != n2 {
                    if n1 != 0 { removeNode(withName: numberNodeName) }
                    if n2 != 0 { addLabel(text: String(n2), fontColor: .white, point: point, nodeName: numberNodeName) }
                }
            }
        }
        for (p, h) in stateFrom.game.pos2hint {
            let (s1, s2) = (stateFrom.pos2state[p]!, stateTo.pos2state[p]!)
            guard s1 != s2 else {continue}
            var point = gridNode.centerPoint(p: p)
            point.x += gridNode.blockSize / 2; point.y -= gridNode.blockSize / 2
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let mathNodeName = "math" + nodeNameSuffix
            removeNode(withName: mathNodeName)
            addMath(h: h, s: s2, point: point, nodeName: mathNodeName)
        }
    }
}
