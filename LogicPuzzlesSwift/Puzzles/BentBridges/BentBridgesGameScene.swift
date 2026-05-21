//
//  BentBridgesGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class BentBridgesGameScene: GameScene<BentBridgesGameState> {
    var gridNode: BentBridgesGridNode {
        get { getGridNode() as! BentBridgesGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addIslandNumber(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: BentBridgesGameState, skView: SKView) {
        let game = game as! BentBridgesGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset: CGFloat = 0.5
        addGrid(gridNode: BentBridgesGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add islands
        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let islandNode = SKShapeNode(circleOfRadius: blockSize / 2)
            islandNode.position = point
            islandNode.name = "island"
            islandNode.strokeColor = .white
            islandNode.glowWidth = 1.0
            gridNode.addChild(islandNode)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let islandNumberNodeName = "islandNumber" + nodeNameSuffix
            addIslandNumber(n: n, s: .normal, point: point, nodeName: islandNumberNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: BentBridgesGameState, to stateTo: BentBridgesGameState) {
        let game = stateFrom.game
        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let bridgesNodeName = { (dir: Int) in "bridges" + nodeNameSuffix + "-\(dir)" }
            let islandNumberNodeName = "islandNumber" + nodeNameSuffix
            func removeIslandNumber() { removeNode(withName: islandNumberNodeName) }
            let (o1, o2) = (stateFrom[p], stateTo[p])
//            if s1 != s2 {
//                removeIslandNumber()
//                addIslandNumber(n: info.bridges, s: s2, point: point, nodeName: islandNumberNodeName)
//            }
        }
    }
}
