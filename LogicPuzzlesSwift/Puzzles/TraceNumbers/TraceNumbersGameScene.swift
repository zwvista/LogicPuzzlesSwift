//
//  TraceNumbersGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class TraceNumbersGameScene: GameScene<TraceNumbersGameState> {
    var gridNode: TraceNumbersGridNode {
        get { getGridNode() as! TraceNumbersGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    override func levelInitialized(_ game: AnyObject, state: TraceNumbersGameState, skView: SKView) {
        let game = game as! TraceNumbersGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: TraceNumbersGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Pearls
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let ch = game[r, c]
                guard ch != " " else {continue}
                let point = gridNode.gridPosition(p: p)
                addLabel(text: String(ch), fontColor: .white, point: point, nodeName: "number")
            }
        }
    }
    
    override func levelUpdated(from stateFrom: TraceNumbersGameState, to stateTo: TraceNumbersGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                for dir in 1...2 {
                    let p = Position(r, c)
                    let point = gridNode.gridPosition(p: p)
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
