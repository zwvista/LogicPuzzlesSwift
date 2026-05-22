//
//  BanquetGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class BanquetGameScene: GameScene<BanquetGameState> {
    var gridNode: BanquetGridNode {
        get { getGridNode() as! BanquetGridNode }
        set { setGridNode(gridNode: newValue) }
    }

    override func levelInitialized(_ game: AnyObject, state: BanquetGameState, skView: SKView) {
        let game = game as! BanquetGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: BanquetGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))

        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let tableNodeName = "table" + nodeNameSuffix
            addLabel(text: String(n), fontColor: .white, point: point, nodeName: tableNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: BanquetGameState, to stateTo: BanquetGameState) {
        let game = stateFrom.game
        for (p, n) in game.pos2hint {
            let (p1, p2) = (stateFrom.hint2table[p]!, stateTo.hint2table[p]!)
            let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
            let point = gridNode.centerPoint(p: p)
            let point2 = gridNode.centerPoint(p: p2)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let tableNodeName = "table" + nodeNameSuffix
            guard p1 != p2 || s1 != s2 else {continue}
            removeNode(withName: tableNodeName)
            if p == p2 {
                addLabel(text: String(n), fontColor: .white, point: point, nodeName: tableNodeName)
            } else {
                addBlock(color: .gray, point: point2, nodeName: tableNodeName)
            }
        }
    }
}
