//
//  HiddenPathGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class HiddenPathGameScene: GameScene<HiddenPathGameState> {
    var gridNode: HiddenPathGridNode {
        get { getGridNode() as! HiddenPathGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addNumber(n: String, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: n, fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName, sampleText: "10")
    }
    
    func addArrow(n: Int, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        addImage(imageNamed: n == 8 ? "star_yellow" : getArrowImageName(n: n), color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName, size: CGSize(width: gridNode.blockSize / 2, height: gridNode.blockSize / 2))
    }

    override func levelInitialized(_ game: AnyObject, state: HiddenPathGameState, skView: SKView) {
        let game = game as! HiddenPathGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: HiddenPathGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addNumbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let arrowNodeName = "arrow" + nodeNameSuffix
                let hint = game.pos2hint[p]!
                let pointImage = CGPoint(x: point.x + blockSize / 4, y: point.y - blockSize / 4)
                addArrow(n: hint, s: .normal, point: pointImage, nodeName: arrowNodeName)
                let (n, s) = (state[p].destructured)
                if n != 0 {
                    let numberNodeName = "number" + nodeNameSuffix
                    addNumber(n: String(n), s: s, point: point, nodeName: numberNodeName)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: HiddenPathGameState, to stateTo: HiddenPathGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let ((n1, s1), (n2, s2)) = (stateFrom[p].destructured, stateTo[p].destructured)
                guard n1 != n2 || s1 != s2 else {continue}
                let numberNodeName = "number" + nodeNameSuffix
                if n1 != 0 {
                    removeNode(withName: numberNodeName)
                }
                if n2 != 0 {
                    addNumber(n: String(n2), s: s2, point: point, nodeName: numberNodeName)
                }
            }
        }
    }
}
