//
//  GuesstrisGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class GuesstrisGameScene: GameScene<GuesstrisGameState> {
    var gridNode: GuesstrisGridNode {
        get { getGridNode() as! GuesstrisGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    override func levelInitialized(_ game: AnyObject, state: GuesstrisGameState, skView: SKView) {
        let game = game as! GuesstrisGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: GuesstrisGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset))
        
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                if game[r, c][1] == .line { addHorzLine(objType: .line, color: .white, point: point, nodeName: "line") }
                if game[r, c][2] == .line { addVertLine(objType: .line, color: .white, point: point, nodeName: "line") }
                guard r < game.rows - 1, c < game.cols - 1 else {continue}
                let ch = game.pos2char[p]!
                guard ch != " " else {continue}
                addImage(imageNamed: ch == GuesstrisGame.PUZ_SQUARE ? "bullet_square_green" : ch == GuesstrisGame.PUZ_TRIANGLE ? "bullet_triangle_yellow_flat" : ch == GuesstrisGame.PUZ_CIRCLE ? "bullet_ball_red" : "bullet_rhombus_blue", color: .red, colorBlendFactor: 0.0, point: point, nodeName: "guesstris")
            }
        }
    }
    
    override func levelUpdated(from stateFrom: GuesstrisGameState, to stateTo: GuesstrisGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let horzLineNodeName = "horzLine" + nodeNameSuffix
                let vertlineNodeName = "vertline" + nodeNameSuffix
                func removeHorzLine(objType: GridLineObject) {
                    if objType != .empty { removeNode(withName: horzLineNodeName) }
                }
                func removeVertLine(objType: GridLineObject) {
                    if objType != .empty { removeNode(withName: vertlineNodeName) }
                }
                var (o1, o2) = (stateFrom[p][1], stateTo[p][1])
                if o1 != o2 {
                    removeHorzLine(objType: o1)
                    addHorzLine(objType: o2, color: .yellow, point: point, nodeName: horzLineNodeName)
                }
                (o1, o2) = (stateFrom[p][2], stateTo[p][2])
                if o1 != o2 {
                    removeVertLine(objType: o1)
                    addVertLine(objType: o2, color: .yellow, point: point, nodeName: vertlineNodeName)
                }
            }
        }
    }
}
