//
//  WarehouseGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class WarehouseGameScene: GameScene<WarehouseGameState> {
    var gridNode: WarehouseGridNode {
        get { getGridNode() as! WarehouseGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addSymbol(ch: Character, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        let imageName = ch == WarehouseGame.PUZ_HORZ ? "navigate_minus" : ch == WarehouseGame.PUZ_VERT ? "navigate_pipe" : "navigate_plus_red"
        addImage(imageNamed: imageName, color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: WarehouseGameState, skView: SKView) {
        let game = game as! WarehouseGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: WarehouseGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset))
        
        // addHints
        for (p, ch) in game.pos2symbol {
            let point = gridNode.gridPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let symbolNodeName = "symbol" + nodeNameSuffix
            addSymbol(ch: ch, s: state.pos2state[p]!, point: point, nodeName: symbolNodeName)
        }
        
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPoint(p: p)
                if game[r, c][1] == .line { addHorzLine(objType: .line, color: .white, point: point, nodeName: "line") }
                if game[r, c][2] == .line { addVertLine(objType: .line, color: .white, point: point, nodeName: "line") }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: WarehouseGameState, to stateTo: WarehouseGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let horzLineNodeName = "horzLine" + nodeNameSuffix
                let vertlineNodeName = "vertline" + nodeNameSuffix
                let symbolNodeName = "symbol" + nodeNameSuffix
                let dotNodeName = "dot" + nodeNameSuffix
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
                if let s1 = stateFrom.pos2state[p], let s2 = stateTo.pos2state[p], s1 != s2 {
                    removeNode(withName: symbolNodeName)
                    addSymbol(ch: stateFrom.game.pos2symbol[p]!, s: s2, point: point, nodeName: symbolNodeName)
                }
                if 1..<stateFrom.rows - 1 ~= r, 1..<stateFrom.cols - 1 ~= c {
                    let (o3, o4) = (stateFrom.dot2state[p]!, stateTo.dot2state[p]!)
                    if o3 != o4 {
                        if o3 == .error { removeNode(withName: dotNodeName) }
                        if o4 == .error { addDotMarker2(color: .red, point: gridNode.dotPoint(p: p), nodeName: dotNodeName) }
                    }
                }
            }
        }
    }
}
