//
//  FussyWaiterGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class FussyWaiterGameScene: GameScene<FussyWaiterGameState> {
    var gridNode: FussyWaiterGridNode {
        get { getGridNode() as! FussyWaiterGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addFlower(s: AllowedObjectState, point: CGPoint, nodeName: String) {
        addImage(imageNamed: "flower_blue", color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName)
    }

    func addForbidden(point: CGPoint, nodeName: String) { addForbiddenMarker(point: point, nodeName: nodeName) }

    override func levelInitialized(_ game: AnyObject, state: FussyWaiterGameState, skView: SKView) {
        let game = game as! FussyWaiterGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: FussyWaiterGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let flowerNodeName = "flower" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                switch state[p] {
                case let .flower(s):
                    addFlower(s: s, point: point, nodeName: flowerNodeName)
                    addCircleMarker(color: .white, point: point, nodeName: "marker")
                case .block:
                    addBlock(color: .white, point: point, nodeName: "block")
                case .forbidden:
                    addForbidden(point: point, nodeName: forbiddenNodeName)
                default:
                    break
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: FussyWaiterGameState, to stateTo: FussyWaiterGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let flowerNodeName = "flower" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                func removeFlower() { removeNode(withName: flowerNodeName) }
                func addMarker() { addDotMarker(point: point, nodeName: markerNodeName) }
                func removeMarker() { removeNode(withName: markerNodeName) }
                func removeForbidden() { removeNode(withName: forbiddenNodeName) }
                let (o1, o2) = (stateFrom[p], stateTo[p])
                guard String(describing: o1) != String(describing: o2) else {continue}
                switch o1 {
                case .forbidden:
                    removeForbidden()
                case .flower:
                    removeFlower()
                case .marker:
                    removeMarker()
                default:
                    break
                }
                switch o2 {
                case .forbidden:
                    addForbidden(point: point, nodeName: forbiddenNodeName)
                case let .flower(s):
                    addFlower(s: s, point: point, nodeName: flowerNodeName)
                case .marker:
                    addMarker()
                default:
                    break
                }
            }
        }
    }
}
