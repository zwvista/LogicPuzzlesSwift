//
//  FreePlanksGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class FreePlanksGameScene: GameScene<FreePlanksGameState> {
    var gridNode: FreePlanksGridNode {
        get { getGridNode() as! FreePlanksGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addNail(point: CGPoint, nodeName: String) {
        addImage(imageNamed: "nail_head", color: .red, colorBlendFactor: 0.0, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: FreePlanksGameState, skView: SKView) {
        let game = game as! FreePlanksGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: FreePlanksGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset))
        
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
    
    override func levelUpdated(from stateFrom: FreePlanksGameState, to stateTo: FreePlanksGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let horzLineNodeName = "horzLine" + nodeNameSuffix
                let vertlineNodeName = "vertline" + nodeNameSuffix
                let nailNodeName = "nail" + nodeNameSuffix
                let plankNodeName = "plank" + nodeNameSuffix
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
                let (b1, b2) = (stateFrom.woods.contains(p), stateTo.woods.contains(p))
                let isNail = stateFrom.game.nails.contains(p)
                if b1 != b2 {
                    if b1 { removeNode(withName: plankNodeName) }
                    if b2 {
                        if isNail { removeNode(withName: nailNodeName) }
                        addImage(imageNamed: "wood horizontal", color: .red, colorBlendFactor: 0.0, point: point, nodeName: plankNodeName)
                        if isNail { addNail(point: point, nodeName: nailNodeName) }
                    }
                }
            }
        }
    }
}
