//
//  BridgesGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class BridgesGameScene: GameScene<BridgesGameState> {
    var gridNode: BridgesGridNode {
        get {return getGridNode() as! BridgesGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addIslandNumber(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: BridgesGameState, skView: SKView) {
        let game = game as! BridgesGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add grid
        let offset: CGFloat = 0.5
        addGrid(gridNode: BridgesGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add islands
        for (p, info) in game.islandsInfo {
            let n = info.bridges
            let point = gridNode.gridPosition(p: p)
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
    
    override func levelUpdated(from stateFrom: BridgesGameState, to stateTo: BridgesGameState) {
        for (p, info) in stateFrom.game.islandsInfo {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let bridgesNodeName = {(dir: Int) in "bridges" + nodeNameSuffix + "-\(dir)"}
            let islandNumberNodeName = "islandNumber" + nodeNameSuffix
            func removeIslandNumber() { removeNode(withName: islandNumberNodeName) }
            func addBridges(dir: Int, bridges: Int) {
                guard bridges > 0 else {return}
                
                let p2 = info.neighbors[dir]!
                let point2 = gridNode.gridPosition(p: p2)
                
                // http://stackoverflow.com/questions/19092011/how-to-draw-a-line-in-sprite-kit
                let pathToDraw = CGMutablePath()
                let bridgesNode = SKShapeNode(path:pathToDraw)
                switch (dir, bridges) {
                case (1, 1):
                    pathToDraw.move(to: CGPoint(x: point.x + gridNode.blockSize / 2, y: point.y))
                    pathToDraw.addLine(to: CGPoint(x: point2.x - gridNode.blockSize / 2, y: point2.y))
                case (1, 2):
                    pathToDraw.move(to: CGPoint(x: point.x + gridNode.blockSize / 2, y: point.y - 5))
                    pathToDraw.addLine(to: CGPoint(x: point2.x - gridNode.blockSize / 2, y: point2.y - 5))
                    pathToDraw.move(to: CGPoint(x: point.x + gridNode.blockSize / 2, y: point.y + 5))
                    pathToDraw.addLine(to: CGPoint(x: point2.x - gridNode.blockSize / 2, y: point2.y + 5))
                case (2, 1):
                    pathToDraw.move(to: CGPoint(x: point.x, y: point.y - gridNode.blockSize / 2))
                    pathToDraw.addLine(to: CGPoint(x: point2.x, y: point2.y + gridNode.blockSize / 2))
                case (2, 2):
                    pathToDraw.move(to: CGPoint(x: point.x - 5, y: point.y - gridNode.blockSize / 2))
                    pathToDraw.addLine(to: CGPoint(x: point2.x - 5, y: point2.y + gridNode.blockSize / 2))
                    pathToDraw.move(to: CGPoint(x: point.x + 5, y: point.y - gridNode.blockSize / 2))
                    pathToDraw.addLine(to: CGPoint(x: point2.x + 5, y: point2.y + gridNode.blockSize / 2))
                default:
                    break
                }
                bridgesNode.path = pathToDraw
                bridgesNode.strokeColor = .yellow
                bridgesNode.glowWidth = 3
                bridgesNode.name = bridgesNodeName(dir)
                gridNode.addChild(bridgesNode)
            }
            func removeBridges(dir: Int, bridges: Int) {
                guard bridges > 0 else {return}
                removeNode(withName: bridgesNodeName(dir))
            }
            let (o1, o2) = (stateFrom[p], stateTo[p])
            guard case let .island(s1, b1) = o1 else {continue}
            guard case let .island(s2, b2) = o2 else {continue}
            if s1 != s2 {
                removeIslandNumber()
                addIslandNumber(n: info.bridges, s: s2, point: point, nodeName: islandNumberNodeName)
            }
            for dir in [1, 2] {
                if b1[dir] != b2[dir] {
                    removeBridges(dir: dir, bridges: b1[dir])
                    addBridges(dir: dir, bridges: b2[dir])
                }
            }
        }
    }
}
