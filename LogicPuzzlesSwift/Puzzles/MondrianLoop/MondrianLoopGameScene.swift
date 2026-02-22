//
//  MondrianLoopGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class MondrianLoopGameScene: GameScene<MondrianLoopGameState> {
    var gridNode: MondrianLoopGridNode {
        get { getGridNode() as! MondrianLoopGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: n == MondrianLoopGame.PUZ_UNKNOWN ? "?" : String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: MondrianLoopGameState, skView: SKView) {
        let game = game as! MondrianLoopGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: MondrianLoopGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset))
        
        // add Hints
        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            let markerNodeName = "marker" + nodeNameSuffix
            addCircleMarker(color: .white, point: point, nodeName: markerNodeName)
            addHint(n: n, s: state.pos2stateHint[p]!, point: point, nodeName: hintNodeName)
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
    
    override func levelUpdated(from stateFrom: MondrianLoopGameState, to stateTo: MondrianLoopGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let horzLineNodeName = "horzLine" + nodeNameSuffix
                let vertlineNodeName = "vertline" + nodeNameSuffix
                func removeHorzLine(objType: GridLineObject) {
                    if objType != .empty { removeNode(withName: horzLineNodeName) }
                }
                func removeVertLine(objType: GridLineObject) {
                    if objType != .empty { removeNode(withName: vertlineNodeName) }
                }
                var (o1, o2) = (stateFrom[p][1], stateTo[p][1])
                if o1 != o2 {
                    removeHorzLine(objType: o1)
                    addHorzLine(objType: o2, color: .yellow, point: point, nodeName: horzLineNodeName)
                }
                (o1, o2) = (stateFrom[p][2], stateTo[p][2])
                if o1 != o2 {
                    removeVertLine(objType: o1)
                    addVertLine(objType: o2, color: .yellow, point: point, nodeName: vertlineNodeName)
                }
                let rectNodeName = "rect" + nodeNameSuffix
                let b1 = stateFrom.rectangles.contains { $0.contains(p) }
                let b2 = stateTo.rectangles.contains { $0.contains(p) }
                if b1 != b2 {
                    if b1 { removeNode(withName: rectNodeName) }
                    if b2 { addImage(imageNamed: "lawn_background", color: .red, colorBlendFactor: 0.0, point: point, nodeName: rectNodeName) }
                }
                let hintNodeName = "hint" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let (s1, s2) = (stateFrom.pos2stateHint[p], stateTo.pos2stateHint[p])
                if s1 != s2 || s1 != nil && b1 != b2 {
                    removeNode(withName: markerNodeName)
                    removeNode(withName: hintNodeName)
                    addCircleMarker(color: .white, point: point, nodeName: markerNodeName)
                    let n = stateFrom.game.pos2hint[p]!
                    addHint(n: n, s: s2!, point: point, nodeName: hintNodeName)
                }
            }
        }
    }
}
