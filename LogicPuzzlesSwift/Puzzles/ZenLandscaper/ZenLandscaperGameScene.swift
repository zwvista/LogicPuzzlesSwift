//
//  ZenLandscaperGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class ZenLandscaperGameScene: GameScene<ZenLandscaperGameState> {
    var gridNode: ZenLandscaperGridNode {
        get { getGridNode() as! ZenLandscaperGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addTile(ch: Character, fixed: Bool, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        let n = ch == " " ? 1 : ch.toInt! + 1
        let imageName = "B\(n)\(fixed ? "-f" : "").jpg"
        addImage(imageNamed: imageName, color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: ZenLandscaperGameState, skView: SKView) {
        let game = game as! ZenLandscaperGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: ZenLandscaperGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                let ch = game[p]
                addTile(ch: ch, fixed: ch != " ", s: .normal, point: point, nodeName: tileNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: ZenLandscaperGameState, to stateTo: ZenLandscaperGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p]!, stateTo.pos2state[p]!)
                guard o1 != o2 || s1 != s2 else {continue}
                removeNode(withName: tileNodeName)
                addTile(ch: o2, fixed: stateFrom.game[p] != " ", s: s2, point: point, nodeName: tileNodeName)
            }
        }
    }
}
