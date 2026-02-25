//
//  OnlyStraightsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class OnlyStraightsGameScene: GameScene<OnlyStraightsGameState> {
    var gridNode: OnlyStraightsGridNode {
        get { getGridNode() as! OnlyStraightsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    let townSize = CGSize(width: 50, height: 50)
    
    func getRightTownPoint(p: Position) -> CGPoint {
        let offset: CGFloat = 0.5
        let x = CGFloat(p.col + 1) * gridNode.blockSize + offset
        let y = -((CGFloat(p.row) + CGFloat(0.5)) * gridNode.blockSize + offset)
        return CGPoint(x: x, y: y)
    }
    
    func getBottomTownPoint(p: Position) -> CGPoint {
        let offset: CGFloat = 0.5
        let x = (CGFloat(p.col) + CGFloat(0.5)) * gridNode.blockSize + offset
        let y = -(CGFloat(p.row + 1) * gridNode.blockSize + offset)
        return CGPoint(x: x, y: y)
    }

    override func levelInitialized(_ game: AnyObject, state: OnlyStraightsGameState, skView: SKView) {
        let game = game as! OnlyStraightsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: OnlyStraightsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Numbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let o = game[p]
                if o.hasCenter {
                    addImage(imageNamed: "lodge", color: .red, colorBlendFactor: 0.0, point: point, nodeName: "town", size: townSize)
                }
                if o.hasRight {
                    let point2 = getRightTownPoint(p: p)
                    addImage(imageNamed: "lodge", color: .red, colorBlendFactor: 0.0, point: point2, nodeName: "town", size: townSize)
                }
                if o.hasBottom {
                    let point4 = getBottomTownPoint(p: p)
                    addImage(imageNamed: "lodge", color: .red, colorBlendFactor: 0.0, point: point4, nodeName: "town", size: townSize)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: OnlyStraightsGameState, to stateTo: OnlyStraightsGameState) {
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
