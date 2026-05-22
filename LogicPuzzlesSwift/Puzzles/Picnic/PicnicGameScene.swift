//
//  PicnicGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class PicnicGameScene: GameScene<PicnicGameState> {
    var gridNode: PicnicGridNode {
        get { getGridNode() as! PicnicGridNode }
        set { setGridNode(gridNode: newValue) }
    }

    override func levelInitialized(_ game: AnyObject, state: PicnicGameState, skView: SKView) {
        let game = game as! PicnicGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: PicnicGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))

        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let blanketNodeName = "blanket" + nodeNameSuffix
            addLabel(text: String(n), fontColor: .white, point: point, nodeName: blanketNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: PicnicGameState, to stateTo: PicnicGameState) {
        let game = stateFrom.game
        for (p, n) in game.pos2hint {
            let (p1, p2) = (stateFrom.hint2blanket[p]!, stateTo.hint2blanket[p]!)
            let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
            let point = gridNode.centerPoint(p: p)
            let point2 = gridNode.centerPoint(p: p2)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let blanketNodeName = "blanket" + nodeNameSuffix
            guard p1 != p2 || s1 != s2 else {continue}
            removeNode(withName: blanketNodeName)
            if p == p2 {
                addLabel(text: String(n), fontColor: .white, point: point, nodeName: blanketNodeName)
            } else {
                addBlock(color: .gray, point: point2, nodeName: blanketNodeName)
            }
        }
    }
}
