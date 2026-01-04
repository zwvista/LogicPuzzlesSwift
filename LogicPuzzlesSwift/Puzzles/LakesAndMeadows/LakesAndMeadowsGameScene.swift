//
//  LakesAndMeadowsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class LakesAndMeadowsGameScene: GameScene<LakesAndMeadowsGameState> {
    var gridNode: LakesAndMeadowsGridNode {
        get { getGridNode() as! LakesAndMeadowsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHole(s: HintState, point: CGPoint, nodeName: String) {
        let holeNode = SKShapeNode(circleOfRadius: gridNode.blockSize / 3)
        holeNode.position = point
        holeNode.name = nodeName
        holeNode.strokeColor = s == .normal ? .white : s == .complete ? .green : .red
        holeNode.glowWidth = 5.0
        holeNode.fillColor = .gray
        gridNode.addChild(holeNode)
    }
    
    override func levelInitialized(_ game: AnyObject, state: LakesAndMeadowsGameState, skView: SKView) {
        let game = game as! LakesAndMeadowsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: LakesAndMeadowsGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset))
        
        for p in game.blocks {
            let point = gridNode.centerPoint(p: p)
            let blockNode = SKSpriteNode(color: .gray, size: coloredRectSize())
            blockNode.position = point
            blockNode.name = "block"
            gridNode.addChild(blockNode)
        }
        for p in game.holes {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let holeNodeName = "hole" + nodeNameSuffix
            addHole(s: .normal, point: point, nodeName: holeNodeName)
        }

        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                if state[r, c][1] == .line { addHorzLine(objType: .line, color: .white, point: point, nodeName: "line") }
                if state[r, c][2] == .line { addVertLine(objType: .line, color: .white, point: point, nodeName: "line") }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: LakesAndMeadowsGameState, to stateTo: LakesAndMeadowsGameState) {
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
            }
        }
        for p in stateFrom.game.holes {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let holeNodeName = "hole" + nodeNameSuffix
            let (s1, s2) = (stateFrom.pos2state[p]!, stateTo.pos2state[p]!)
            if s1 != s2 {
                removeNode(withName: holeNodeName)
                addHole(s: s2, point: point, nodeName: holeNodeName)
            }
        }
    }
}
