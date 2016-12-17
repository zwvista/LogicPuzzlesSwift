//
//  AbcGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class AbcGameScene: GameScene<AbcGameState> {
    var gridNode: AbcGridNode {
        get {return getGridNode() as! AbcGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addCharacter(ch: Character, s: HintState, isHint: Bool, point: CGPoint, nodeName: String) {
        addLabel(text: String(ch), fontColor: s == .normal ? isHint ? .gray : .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: AbcGameState, skView: SKView) {
        let game = game as! AbcGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: AbcGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Characters
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let ch = state[p]
                guard ch != " " else {continue}
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let charNodeName = "char" + nodeNameSuffix
                let s = state.pos2state(row: r, col: c)
                addCharacter(ch: ch, s: s, isHint: !game.isValid(p: p), point: point, nodeName: charNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: AbcGameState, to stateTo: AbcGameState) {
        for row in 0..<stateFrom.rows {
            for col in 0..<stateFrom.cols {
                let p = Position(row, col)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(row)-\(col)"
                let charNodeName = "char" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                func removeCharacter() { removeNode(withName: charNodeName) }
                func addMarker() { addDotMarker(point: point, nodeName: markerNodeName) }
                func removeMarker() { removeNode(withName: markerNodeName) }
                let (ch1, ch2) = (stateFrom[row, col], stateTo[row, col])
                let (s1, s2) = (stateFrom.pos2state(row: row, col: col), stateTo.pos2state(row: row, col: col))
                guard ch1 != ch2 || s1 != s2 else {continue}
                if ch1 == "." {
                    removeMarker()
                } else if (ch1 != " ") {
                    removeCharacter()
                }
                if ch2 == "." {
                    addMarker()
                } else if (ch2 != " ") {
                    addCharacter(ch: ch2, s: s2, isHint: !stateFrom.game.isValid(p: p), point: point, nodeName: charNodeName)
                }
            }
        }
    }
}
