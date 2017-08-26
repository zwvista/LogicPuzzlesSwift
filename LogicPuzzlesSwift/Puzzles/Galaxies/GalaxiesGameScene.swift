//
//  GalaxiesGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class GalaxiesGameScene: GameScene<GalaxiesGameState> {
    var gridNode: GalaxiesGridNode {
        get {return getGridNode() as! GalaxiesGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addGalaxy(s: HintState, point: CGPoint, nodeName: String) {
        addDotMarker2(color: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: GalaxiesGameState, skView: SKView) {
        let game = game as! GalaxiesGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: GalaxiesGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset))
        
        // addHints
        for p in game.galaxies {
            var point = gridNode.gridPosition(p: Position(p.row / 2, p.col / 2))
            point = CGPoint(x: point.x - (p.col % 2 == 0 ? blockSize / 2 : 0),
                            y: point.y + (p.row % 2 == 0 ? blockSize / 2 : 0))
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addGalaxy(s: state.pos2state[p]!, point: point, nodeName: hintNodeName)
        }
        
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                if game[r, c][1] == .line {addHorzLine(objType: .line, color: .white, point: point, nodeName: "line")}
                if game[r, c][2] == .line {addVertLine(objType: .line, color: .white, point: point, nodeName: "line")}
            }
        }
    }
    
    override func levelUpdated(from stateFrom: GalaxiesGameState, to stateTo: GalaxiesGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
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
                let hintNodeName = "hint" + nodeNameSuffix
                func removeGalaxy() { removeNode(withName: hintNodeName) }
                guard let s1 = stateFrom.pos2state[p], let s2 = stateTo.pos2state[p] else {continue}
                if s1 != s2 {
                    removeGalaxy()
                    addGalaxy(s: s2, point: point, nodeName: hintNodeName)
                }
            }
        }
    }
}
