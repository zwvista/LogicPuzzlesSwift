//
//  ParksGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class ParksGameScene: GameScene<ParksGameState> {
    var gridNode: ParksGridNode {
        get {return getGridNode() as! ParksGridNode}
        set {setGridNode(gridNode: newValue)}
    }

    override func levelInitialized(_ game: AnyObject, state: ParksGameState, skView: SKView) {
        let game = game as! ParksGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: ParksGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path: pathToDraw)
        for row in 0..<game.rows + 1 {
            for col in 0..<game.cols + 1 {
                let p = Position(row, col)
                let point = gridNode.gridPosition(p: p)
                for dir in 1...2 {
                    guard game.dots[row, col, dir] else {continue}
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
        lineNode.strokeColor = .yellow
        lineNode.name = "line"
        gridNode.addChild(lineNode)
    }
    
    override func levelUpdated(from stateFrom: ParksGameState, to stateTo: ParksGameState) {
        for row in 0..<stateFrom.rows {
            for col in 0..<stateFrom.cols {
                let p = Position(row, col)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(row)-\(col)"
                let treeNodeName = "tree" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                func addTree(s: AllowedObjectState) {
                    addImage(imageNamed: "lightbulb", color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.2, point: point, nodeName: treeNodeName)
                }
                func removeTree() { removeNode(withName: treeNodeName) }
                func addMarker() {
                    let markerNode = SKShapeNode(circleOfRadius: 5)
                    markerNode.position = point
                    markerNode.name = markerNodeName
                    markerNode.strokeColor = .white
                    markerNode.glowWidth = 1.0
                    markerNode.fillColor = .white
                    gridNode.addChild(markerNode)
                }
                func removeMarker() { removeNode(withName: markerNodeName) }
                let (o1, o2) = (stateFrom[p], stateTo[p])
                guard String(describing: o1) == String(describing: o2) else {continue}
                switch o1 {
                case .tree:
                    removeTree()
                case .marker:
                    removeMarker()
                default:
                    break
                }
                switch o2 {
                case let .tree(s):
                    addTree(s: s)
                case .marker:
                    addMarker()
                default:
                    break
                }
            }
        }
    }
}
