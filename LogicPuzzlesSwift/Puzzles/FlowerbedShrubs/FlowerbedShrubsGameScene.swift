//
//  FlowerbedShrubsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class FlowerbedShrubsGameScene: GameScene<FlowerbedShrubsGameState> {
    var gridNode: FlowerbedShrubsGridNode {
        get { getGridNode() as! FlowerbedShrubsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    func addLines(game: FlowerbedShrubsGame) {
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                if game[p][1] == .line { addHorzLine(objType: .line, color: .white, point: point, nodeName: "line") }
                if game[p][2] == .line { addVertLine(objType: .line, color: .white, point: point, nodeName: "line") }
            }
        }
    }

    override func levelInitialized(_ game: AnyObject, state: FlowerbedShrubsGameState, skView: SKView) {
        let game = game as! FlowerbedShrubsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: FlowerbedShrubsGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset))
        
        // add Hints
        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: state.pos2stateHint[p]!, point: point, nodeName: hintNodeName)
        }
        
        addLines(game: game)
    }
    
    override func levelUpdated(from stateFrom: FlowerbedShrubsGameState, to stateTo: FlowerbedShrubsGameState) {
        let game = stateFrom.game
        var rng = Set<Position>()
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let shrubNodeName = "shrub" + nodeNameSuffix
                let (b1, b2) = (stateFrom.shrubs.contains(p), stateTo.shrubs.contains(p))
                let (s3, s4) = (stateFrom.pos2stateAllowed[p], stateTo.pos2stateAllowed[p])
                if b1 != b2 || s3 != s4 {
                    if b1 { removeNode(withName: shrubNodeName) }
                    if b2 {
                        addImage(imageNamed: "lawn_background", color: .red, colorBlendFactor: s4 == .normal ? 0.0 : 0.5, point: point, nodeName: shrubNodeName)
                        for os in FlowerbedShrubsGame.offset3 {
                            rng.insert(p + os)
                        }
                    }
                }
            }
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let horzLineNodeName = "horzLine" + nodeNameSuffix
                let vertlineNodeName = "vertline" + nodeNameSuffix
                var (o1, o2) = (stateFrom[p][1], stateTo[p][1])
                if o1 != o2 || rng.contains(p) && game[p][1] != .line {
                    removeHorzLine(objType: o1, nodeName: horzLineNodeName)
                    addHorzLine(objType: o2, color: .yellow, point: point, nodeName: horzLineNodeName)
                }
                (o1, o2) = (stateFrom[p][2], stateTo[p][2])
                if o1 != o2 || rng.contains(p) && game[p][2] != .line {
                    removeVertLine(objType: o1, nodeName: vertlineNodeName)
                    addVertLine(objType: o2, color: .yellow, point: point, nodeName: vertlineNodeName)
                }
                let hintNodeName = "hint" + nodeNameSuffix
                func removeHint() { removeNode(withName: hintNodeName) }
                let (s1, s2) = (stateFrom.pos2stateHint[p], stateTo.pos2stateHint[p])
                if s1 != s2 {
                    removeHint()
                    addHint(n: game.pos2hint[p]!, s: s2!, point: point, nodeName: hintNodeName)
                }
            }
        }

        removeNode(withName: "line")
        addLines(game: game)
    }
}
