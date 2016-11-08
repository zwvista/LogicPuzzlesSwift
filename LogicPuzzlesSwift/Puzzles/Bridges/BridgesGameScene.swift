//
//  BridgesGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class BridgesGameScene: GameScene<BridgesGameState> {
    private(set) var gridNode: BridgesGridNode!
    
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
    
    override func levelInitialized(_ game: AnyObject, state: BridgesGameState, skView: SKView) {
        let game = game as! BridgesGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add grid
        let offset: CGFloat = 0.5
        scaleMode = .resizeFill
        gridNode = BridgesGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols)
        gridNode.position = CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset)
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
        
        // add islands
        for (p, info) in game.islandsInfo {
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
    
    override func levelUpdated(from stateFrom: BridgesGameState, to stateTo: BridgesGameState) {
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
                bridgesNode.strokeColor = SKColor.yellow
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
