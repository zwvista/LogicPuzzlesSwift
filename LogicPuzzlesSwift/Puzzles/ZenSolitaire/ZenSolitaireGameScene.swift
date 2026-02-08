//
//  ZenSolitaireGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class ZenSolitaireGameScene: GameScene<ZenSolitaireGameState> {
    var gridNode: ZenSolitaireGridNode {
        get { getGridNode() as! ZenSolitaireGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    override func levelInitialized(_ game: AnyObject, state: ZenSolitaireGameState, skView: SKView) {
        let game = game as! ZenSolitaireGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: ZenSolitaireGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let n = state[p]
                addImage(imageNamed: "sand_background", color: .red, colorBlendFactor: 0.0, point: point, nodeName: "background")
                guard n == ZenSolitaireGame.PUZ_STONE else {continue}
                addImage(imageNamed: "pebble1", color: .red, colorBlendFactor: 0.0, point: point, nodeName: "stone")
            }
        }
    }
    
    override func levelUpdated(from stateFrom: ZenSolitaireGameState, to stateTo: ZenSolitaireGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                guard o1 != o2 else {continue}
                if o1 != ZenSolitaireGame.PUZ_STONE { removeNode(withName: numberNodeName) }
                if o2 != ZenSolitaireGame.PUZ_STONE { addLabel(text: String(o2), fontColor: .black, point: point, nodeName: numberNodeName) }
            }
        }
    }
}
