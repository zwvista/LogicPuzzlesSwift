//
//  AbcGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class AbcGameScene: GameScene<AbcGameState> {
    var gridNode: AbcGridNode!
    
    func coloredRectSize() -> CGSize {
        let sz = gridNode.blockSize - 4
        return CGSize(width: sz, height: sz)
    }
    
    func addCharacter(ch: Character, s: HintState, isHint: Bool, point: CGPoint, nodeName: String) {
        addLabel(parentNode: gridNode, text: String(ch), fontColor: s == .normal ? isHint ? .gray : .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: AbcGameState, skView: SKView) {
        let game = game as! AbcGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        gridNode = AbcGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols)
        gridNode.position = CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset)
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
        
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
                func removeNode(withName: String) {
                    gridNode.enumerateChildNodes(withName: withName) { (node, pointer) in
                        node.removeFromParent()
                    }
                }
                func removeCharacter() { removeNode(withName: charNodeName) }
                let (ch1, ch2) = (stateFrom[row, col], stateTo[row, col])
                let (s1, s2) = (stateFrom.pos2state(row: row, col: col), stateTo.pos2state(row: row, col: col))
                guard ch1 != ch2 || s1 != s2 else {continue}
                if (ch1 != " ") {removeCharacter()}
                if (ch2 != " ") {addCharacter(ch: ch2, s: s2, isHint: !stateFrom.game.isValid(p: p), point: point, nodeName: charNodeName)}
            }
        }
    }
}
