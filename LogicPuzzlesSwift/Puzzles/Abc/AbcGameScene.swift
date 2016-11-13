//
//  AbcGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class AbcGameScene: GameScene<AbcGameState> {
    var gridNode: AbcGridNode { return childNode(withName: "grid") as! AbcGridNode }
    
    func coloredRectSize() -> CGSize {
        let sz = gridNode.blockSize - 4
        return CGSize(width: sz, height: sz)
    }
    
    func addCharacter(ch: Character, s: HintState, point: CGPoint, nodeName: String) {
        let labelNode = SKLabelNode(text: String(ch))
        labelNode.fontColor = s == .normal ? SKColor.white : s == .complete ? SKColor.green : SKColor.red
        labelNode.fontName = labelNode.fontName! + "-Bold"
        // http://stackoverflow.com/questions/32144666/resize-a-sklabelnode-font-size-to-fit
        let scalingFactor = min(gridNode.blockSize / labelNode.frame.width, gridNode.blockSize / labelNode.frame.height)
        labelNode.fontSize *= scalingFactor
        labelNode.verticalAlignmentMode = .center
        labelNode.position = point
        labelNode.name = nodeName
        gridNode.addChild(labelNode)
    }
    
    override func levelInitialized(_ game: AnyObject, state: AbcGameState, skView: SKView) {
        let game = game as! AbcGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        let gridNode = AbcGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols)
        gridNode.position = CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset)
        gridNode.name = "grid"
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
        
        // add Characters
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let ch = state[p]
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let charNodeName = "char" + nodeNameSuffix
                let s = state.pos2state(row: r, col: c)
                addCharacter(ch: ch, s: s, point: point, nodeName: charNodeName)
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
                removeCharacter()
                addCharacter(ch: ch2, s: s2, point: point, nodeName: charNodeName)
            }
        }
    }
}
