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
            let (s1, s2) = (stateFrom.pos2state[p1], stateTo.pos2state[p2])
            let point = gridNode.centerPoint(p: p)
            let point2 = gridNode.centerPoint(p: p2)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let blanketNodeName = "blanket" + nodeNameSuffix
            guard p1 != p2 || s1 != s2 else {continue}
            removeNode(withName: blanketNodeName)
            if p == p2 {
                addLabel(text: String(n), fontColor: .white, point: point, nodeName: blanketNodeName)
            } else {
                addImage(imageNamed: "mat", color: .red, colorBlendFactor: s2 == .normal ? 0.0 : 0.5, point: point2, nodeName: blanketNodeName)
                let pathToDraw = CGMutablePath()
                let lineNode = SKShapeNode(path:pathToDraw)
                lineNode.glowWidth = 4
                pathToDraw.move(to: CGPoint(x: point.x, y: point.y))
                pathToDraw.addLine(to: CGPoint(x: point2.x, y: point2.y))
                lineNode.path = pathToDraw
                lineNode.strokeColor = .green
                lineNode.name = blanketNodeName
                gridNode.addChild(lineNode)
            }
        }
    }
}
