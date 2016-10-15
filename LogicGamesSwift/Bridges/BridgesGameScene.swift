//
//  BridgesGameScene.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class BridgesGameScene: SKScene {
    private(set) var gridNode: BridgesGridNode!
    
    func addGrid(to view: SKView, rows: Int, cols: Int, blockSize: CGFloat) {
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        gridNode = BridgesGridNode(blockSize: blockSize, rows: rows, cols: cols)
        gridNode.position = CGPoint(x: view.frame.midX - gridNode.blockSize * CGFloat(gridNode.cols) / 2 - offset, y: view.frame.midY + gridNode.blockSize * CGFloat(gridNode.rows) / 2 + offset)
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
    }
    
    func addIslands(from state: BridgesGameState) {
        for (p, info) in state.game.islandsInfo {
            let n = info.bridges
            let point = gridNode.gridPosition(p: p)
            let islandNode = SKShapeNode(circleOfRadius: gridNode.blockSize / 2)
            islandNode.position = point
            islandNode.name = "island"
            islandNode.strokeColor = SKColor.white
            islandNode.glowWidth = 1.0
            gridNode.addChild(islandNode)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let islandNumberNodeName = "islandNumber" + nodeNameSuffix
            addIslandNumber(n: n, s: .normal, point: point, nodeName: islandNumberNodeName)
        }
    }
    
    func addIslandNumber(n: Int, s: BridgesIslandState, point: CGPoint, nodeName: String) {
        let numberNode = SKLabelNode(text: String(n))
        numberNode.fontColor = s == .normal ? SKColor.white : s == .complete ? SKColor.green : SKColor.red
        numberNode.fontName = numberNode.fontName! + "-Bold"
        // http://stackoverflow.com/questions/32144666/resize-a-sklabelnode-font-size-to-fit
        let scalingFactor = min(gridNode.blockSize / numberNode.frame.width, gridNode.blockSize / numberNode.frame.height)
        numberNode.fontSize *= scalingFactor
        numberNode.verticalAlignmentMode = .center
        numberNode.position = point
        numberNode.name = nodeName
        gridNode.addChild(numberNode)
    }
    
    func process(from stateFrom: BridgesGameState, to stateTo: BridgesGameState) {
        for (p, info) in stateFrom.game.islandsInfo {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let bridgesNodeName = {(dir: Int) in "bridges" + nodeNameSuffix + "-\(dir)"}
            let islandNumberNodeName = "islandNumber" + nodeNameSuffix
            func removeNode(withName: String) {
                gridNode.enumerateChildNodes(withName: withName) { (node, pointer) in
                    node.removeFromParent()
                }
            }
            func removeIslandNumber() { removeNode(withName: islandNumberNodeName) }
            func addBridges(dir: Int) {
            }
            func removeBridges(dir: Int) { removeNode(withName: bridgesNodeName(dir)) }
            let (o1, o2) = (stateFrom[p], stateTo[p])
            guard case let .island(s1, b1) = o1 else {continue}
            guard case let .island(s2, b2) = o2 else {continue}
            if s1 != s2 {
                removeIslandNumber()
                addIslandNumber(n: info.bridges, s: s2, point: point, nodeName: islandNumberNodeName)
            }
            for dir in [1, 2] {
                if b1[dir] != b2[dir] {
                    removeBridges(dir: dir)
                    addBridges(dir: dir)
                }
            }
        }
    }
}
