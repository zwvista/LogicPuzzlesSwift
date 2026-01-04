//
//  StraightAndTurnGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class StraightAndTurnGameScene: GameScene<StraightAndTurnGameState> {
    var gridNode: StraightAndTurnGridNode {
        get { getGridNode() as! StraightAndTurnGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    override func levelInitialized(_ game: AnyObject, state: StraightAndTurnGameState, skView: SKView) {
        let game = game as! StraightAndTurnGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: StraightAndTurnGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Pearls
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let ch = game[r, c]
                guard ch != " " else {continue}
                let point = gridNode.centerPoint(p: p)
                let pearlNode = SKShapeNode(circleOfRadius: gridNode.blockSize / 2)
                pearlNode.position = point
                pearlNode.name = "pearl"
                pearlNode.strokeColor = .white
                pearlNode.fillColor = ch == "W" ? .white : .black
                pearlNode.glowWidth = 1.0
                gridNode.addChild(pearlNode)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: StraightAndTurnGameState, to stateTo: StraightAndTurnGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                for dir in 1...2 {
                    let p = Position(r, c)
                    let point = gridNode.centerPoint(p: p)
                    let nodeNameSuffix = "-\(r)-\(c)-\(dir)"
                    let lineNodeName = "line" + nodeNameSuffix
                    func removeLine() { removeNode(withName: lineNodeName) }
                    func addLine() {
                        let pathToDraw = CGMutablePath()
                        let lineNode = SKShapeNode(path:pathToDraw)
                        lineNode.glowWidth = 8
                        switch dir {
                        case 1:
                            pathToDraw.move(to: CGPoint(x: point.x, y: point.y))
                            pathToDraw.addLine(to: CGPoint(x: point.x + gridNode.blockSize, y: point.y))
                        case 2:
                            pathToDraw.move(to: CGPoint(x: point.x, y: point.y))
                            pathToDraw.addLine(to: CGPoint(x: point.x, y: point.y - gridNode.blockSize))
                        default:
                            break
                        }
                        lineNode.path = pathToDraw
                        lineNode.strokeColor = .green
                        lineNode.name = lineNodeName
                        gridNode.addChild(lineNode)
                    }
                    let (o1, o2) = (stateFrom[p][dir], stateTo[p][dir])
                    guard o1 != o2 else {continue}
                    if o1 { removeLine() }
                    if o2 { addLine() }
                 }
            }
        }
    }
}
