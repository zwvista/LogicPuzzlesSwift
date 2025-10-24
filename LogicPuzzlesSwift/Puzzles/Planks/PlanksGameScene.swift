//
//  PlanksGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class PlanksGameScene: GameScene<PlanksGameState> {
    var gridNode: PlanksGridNode {
        get { getGridNode() as! PlanksGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addNail(point: CGPoint, nodeName: String) {
        addImage(imageNamed: "nail_head", color: .red, colorBlendFactor: 0.0, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: PlanksGameState, skView: SKView) {
        let game = game as! PlanksGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: PlanksGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset))
        
        // add Nails
        for p in game.nails {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let nailNodeName = "nail" + nodeNameSuffix
            addNail(point: point, nodeName: nailNodeName)
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
    
    override func levelUpdated(from stateFrom: PlanksGameState, to stateTo: PlanksGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let horzLineNodeName = "horzLine" + nodeNameSuffix
                let vertlineNodeName = "vertline" + nodeNameSuffix
                let nailNodeName = "nail" + nodeNameSuffix
                let plankNodeName = "plank" + nodeNameSuffix
                let (e1, e2) = (stateFrom.pos2orient[p], stateTo.pos2orient[p])
                let isNail = stateFrom.game.nails.contains(p)
                if e1 != e2 {
                    if e1 != nil { removeNode(withName: plankNodeName) }
                    if let e2 {
                        if isNail { removeNode(withName: nailNodeName) }
                        addImage(imageNamed: "wood \(e2 ? "horizontal" : "vertical")", color: .red, colorBlendFactor: 0.0, point: point, nodeName: plankNodeName)
                        if isNail { addNail(point: point, nodeName: nailNodeName) }
                    }
                }
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
            }
        }
    }
}
