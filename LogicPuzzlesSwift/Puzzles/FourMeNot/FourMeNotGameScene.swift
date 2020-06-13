//
//  FourMeNotGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class FourMeNotGameScene: GameScene<FourMeNotGameState> {
    var gridNode: FourMeNotGridNode {
        get { getGridNode() as! FourMeNotGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addTree(s: AllowedObjectState, point: CGPoint, nodeName: String) {
        addImage(imageNamed: "tree", color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName)
    }

    func addForbidden(point: CGPoint, nodeName: String) { addForbiddenMarker(point: point, nodeName: nodeName) }

    override func levelInitialized(_ game: AnyObject, state: FourMeNotGameState, skView: SKView) {
        let game = game as! FourMeNotGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: FourMeNotGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addHint
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let treeNodeName = "tree" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                switch state[p] {
                case let .tree(s):
                    addTree(s: s, point: point, nodeName: treeNodeName)
                    addCircleMarker(color: .white, point: point, nodeName: "marker")
                case .block:
                    let blockNode = SKSpriteNode(color: .white, size: coloredRectSize())
                    blockNode.position = point
                    blockNode.name = "block"
                    gridNode.addChild(blockNode)
                case .forbidden:
                    addForbidden(point: point, nodeName: forbiddenNodeName)
                default:
                    break
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: FourMeNotGameState, to stateTo: FourMeNotGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let treeNodeName = "tree" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                func removeTree() { removeNode(withName: treeNodeName) }
                func addMarker() { addDotMarker(point: point, nodeName: markerNodeName) }
                func removeMarker() { removeNode(withName: markerNodeName) }
                func removeForbidden() { removeNode(withName: forbiddenNodeName) }
                let (o1, o2) = (stateFrom[p], stateTo[p])
                guard String(describing: o1) != String(describing: o2) else {continue}
                switch o1 {
                case .forbidden:
                    removeForbidden()
                case .tree:
                    removeTree()
                case .marker:
                    removeMarker()
                default:
                    break
                }
                switch o2 {
                case .forbidden:
                    addForbidden(point: point, nodeName: forbiddenNodeName)
                case let .tree(s):
                    addTree(s: s, point: point, nodeName: treeNodeName)
                case .marker:
                    addMarker()
                default:
                    break
                }
            }
        }
    }
}
