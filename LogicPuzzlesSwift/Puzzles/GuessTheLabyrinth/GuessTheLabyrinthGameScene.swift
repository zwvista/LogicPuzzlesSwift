//
//  GuessTheLabyrinthGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class GuessTheLabyrinthGameScene: GameScene<GuessTheLabyrinthGameState> {
    var gridNode: GuessTheLabyrinthGridNode {
        get { getGridNode() as! GuessTheLabyrinthGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    override func levelInitialized(_ game: AnyObject, state: GuessTheLabyrinthGameState, skView: SKView) {
        let game = game as! GuessTheLabyrinthGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: GuessTheLabyrinthGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset))
        
        // add Images
        for p in game.wolves {
            let point = gridNode.centerPoint(p: p)
            addImage(imageNamed: "wolf2", color: .red, colorBlendFactor: 0.0, point: point, nodeName: "wolf")
        }
        for p in game.sheep {
            let point = gridNode.centerPoint(p: p)
            addImage(imageNamed: "sheep2", color: .red, colorBlendFactor: 0.0, point: point, nodeName: "sheep")
        }
        for p in game.posts {
            let point = gridNode.cornerPoint(p: p)
            addDotMarker2(color: .white, point: point, nodeName: "post")
        }
        
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                if game[p][1] == .line { addHorzLine(objType: .line, color: .white, point: point, nodeName: "line") }
                if game[p][2] == .line { addVertLine(objType: .line, color: .white, point: point, nodeName: "line") }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: GuessTheLabyrinthGameState, to stateTo: GuessTheLabyrinthGameState) {
        let game = stateFrom.game
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let horzLineNodeName = "horzLine" + nodeNameSuffix
                let vertlineNodeName = "vertline" + nodeNameSuffix
                var (o1, o2) = (stateFrom[p][1], stateTo[p][1])
                if o1 != o2 {
                    removeHorzLine(objType: o1, nodeName: horzLineNodeName)
                    addHorzLine(objType: o2, color: .yellow, point: point, nodeName: horzLineNodeName)
                }
                (o1, o2) = (stateFrom[p][2], stateTo[p][2])
                if o1 != o2 {
                    removeVertLine(objType: o1, nodeName: vertlineNodeName)
                    addVertLine(objType: o2, color: .yellow, point: point, nodeName: vertlineNodeName)
                }
            }
        }
    }
}
