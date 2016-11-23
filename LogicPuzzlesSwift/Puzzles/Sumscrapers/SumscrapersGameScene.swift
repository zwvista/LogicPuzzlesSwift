//
//  SumscrapersGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class SumscrapersGameScene: GameScene<SumscrapersGameState> {
    private(set) var gridNode: SumscrapersGridNode!
    
    func coloredRectSize() -> CGSize {
        let sz = gridNode.blockSize - 4
        return CGSize(width: sz, height: sz)
    }
    
    func addNumber(n: Int, s: HintState, isHint: Bool, point: CGPoint, nodeName: String) {
        let labelNode = SKLabelNode(text: String(n))
        labelNode.fontColor = s == .normal ? isHint ? SKColor.gray : SKColor.white : s == .complete ? SKColor.green : SKColor.red
        labelNode.fontName = labelNode.fontName! + "-Bold"
        // http://stackoverflow.com/questions/32144666/resize-a-sklabelnode-font-size-to-fit
        let scalingFactor = min(gridNode.blockSize / labelNode.frame.width, gridNode.blockSize / labelNode.frame.height)
        labelNode.fontSize *= scalingFactor
        labelNode.verticalAlignmentMode = .center
        labelNode.position = point
        labelNode.name = nodeName
        gridNode.addChild(labelNode)
    }
    
    override func levelInitialized(_ game: AnyObject, state: SumscrapersGameState, skView: SKView) {
        let game = game as! SumscrapersGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        gridNode = SumscrapersGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols)
        gridNode.position = CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset)
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
        
        // add Numbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let n = state[p]
                guard n != 0 else {continue}
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let numNodeName = "num" + nodeNameSuffix
                let s = state.pos2state(row: r, col: c)
                addNumber(n: n, s: s, isHint: !game.isValid(p: p), point: point, nodeName: numNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: SumscrapersGameState, to stateTo: SumscrapersGameState) {
        for row in 0..<stateFrom.rows {
            for col in 0..<stateFrom.cols {
                let p = Position(row, col)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(row)-\(col)"
                let numNodeName = "num" + nodeNameSuffix
                func removeNode(withName: String) {
                    gridNode.enumerateChildNodes(withName: withName) { (node, pointer) in
                        node.removeFromParent()
                    }
                }
                func removeNumber() { removeNode(withName: numNodeName) }
                let (n1, n2) = (stateFrom[row, col], stateTo[row, col])
                let (s1, s2) = (stateFrom.pos2state(row: row, col: col), stateTo.pos2state(row: row, col: col))
                guard n1 != n2 || s1 != s2 else {continue}
                if (n1 != 0) {removeNumber()}
                if (n2 != 0) {addNumber(n: n2, s: s2, isHint: !stateFrom.game.isValid(p: p), point: point, nodeName: numNodeName)}
            }
        }
    }
}
