//
//  StraightAndBendLandsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class StraightAndBendLandsGameScene: GameScene<StraightAndBendLandsGameState> {
    var gridNode: StraightAndBendLandsGridNode {
        get { getGridNode() as! StraightAndBendLandsGridNode }
        set { setGridNode(gridNode: newValue) }
    }

    override func levelInitialized(_ game: AnyObject, state: StraightAndBendLandsGameState, skView: SKView) {
        let game = game as! StraightAndBendLandsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: StraightAndBendLandsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path: pathToDraw)
        for r in 0..<game.rows + 1 {
            for c in 0..<game.cols + 1 {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                for dir in 1...2 {
                    guard game.dots[r, c][dir] == .line else {continue}
                    switch dir {
                    case 1:
                        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        pathToDraw.addLine(to: CGPoint(x: point.x + gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        lineNode.glowWidth = 8
                    case 2:
                        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        pathToDraw.addLine(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y - gridNode.blockSize / 2))
                        lineNode.glowWidth = 8
                    default:
                        break
                    }
                }
            }
        }
        lineNode.path = pathToDraw
        lineNode.name = "line"
        gridNode.addChild(lineNode)
        
        // add Images
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let ch = game[r, c]
                guard ch != " " else {continue}
                let point = gridNode.centerPoint(p: p)
                addImage(imageNamed: ch == StraightAndBendLandsGame.PUZ_HOUSE ? "lodge" : "tree", color: .red, colorBlendFactor: 0.0, point: point, nodeName: "lands")
            }
        }
    }
    
    override func levelUpdated(from stateFrom: StraightAndBendLandsGameState, to stateTo: StraightAndBendLandsGameState) {
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
