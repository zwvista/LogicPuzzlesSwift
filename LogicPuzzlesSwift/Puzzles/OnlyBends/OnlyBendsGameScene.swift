//
//  OnlyBendsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class OnlyBendsGameScene: GameScene<OnlyBendsGameState> {
    var gridNode: OnlyBendsGridNode {
        get { getGridNode() as! OnlyBendsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    override func levelInitialized(_ game: AnyObject, state: OnlyBendsGameState, skView: SKView) {
        let game = game as! OnlyBendsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: OnlyBendsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Numbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let ch = game[r, c]
                guard ch != " " else {continue}
                let point = gridNode.centerPoint(p: p)
                addImage(imageNamed: "lodge", color: .red, colorBlendFactor: 0.0, point: point, nodeName: "lodge")
            }
        }
    }
    
    override func levelUpdated(from stateFrom: OnlyBendsGameState, to stateTo: OnlyBendsGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                for dir in 1...2 {
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
