//
//  IslandConnectionsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class IslandConnectionsGameScene: GameScene<IslandConnectionsGameState> {
    var gridNode: IslandConnectionsGridNode {
        get { getGridNode() as! IslandConnectionsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addIslandNumber(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: IslandConnectionsGameState, skView: SKView) {
        let game = game as! IslandConnectionsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset: CGFloat = 0.5
        addGrid(gridNode: IslandConnectionsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                addImage(imageNamed: "sea", color: .red, colorBlendFactor: 0.0, point: point, nodeName: "sea")
            }
        }
        
        // add islands
        for (p, info) in game.islandsInfo {
            let n = info.bridges
            let point = gridNode.centerPoint(p: p)
            let islandNode = SKShapeNode(circleOfRadius: blockSize / 2)
            islandNode.position = point
            islandNode.name = "island"
            islandNode.strokeColor = .white
            islandNode.glowWidth = 1.0
            gridNode.addChild(islandNode)
            guard n >= 0 else {continue}
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let islandNumberNodeName = "islandNumber" + nodeNameSuffix
            addIslandNumber(n: n, s: .normal, point: point, nodeName: islandNumberNodeName)
        }
        
        for p in game.shaded {
            let point = gridNode.centerPoint(p: p)
            let shadedNode = SKShapeNode(circleOfRadius: blockSize / 2)
            shadedNode.position = point
            shadedNode.name = "shaded"
            shadedNode.fillColor = .white
            shadedNode.glowWidth = 1.0
            gridNode.addChild(shadedNode)
        }
    }
    
    override func levelUpdated(from stateFrom: IslandConnectionsGameState, to stateTo: IslandConnectionsGameState) {
        for (p, info) in stateFrom.game.islandsInfo {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let bridgesNodeName = { (dir: Int) in "bridges" + nodeNameSuffix + "-\(dir)" }
            let islandNumberNodeName = "islandNumber" + nodeNameSuffix
            func removeIslandNumber() { removeNode(withName: islandNumberNodeName) }
            func addIslandConnections(dir: Int, bridges: Int) {
                guard bridges > 0 else {return}
                
                let p2 = info.neighbors[dir]!
                let point2 = gridNode.centerPoint(p: p2)
                
                // http://stackoverflow.com/questions/19092011/how-to-draw-a-line-in-sprite-kit
                let pathToDraw = CGMutablePath()
                let bridgesNode = SKShapeNode(path:pathToDraw)
                switch (dir, bridges) {
                case (1, 1):
                    pathToDraw.move(to: CGPoint(x: point.x + gridNode.blockSize / 2, y: point.y))
                    pathToDraw.addLine(to: CGPoint(x: point2.x - gridNode.blockSize / 2, y: point2.y))
                case (2, 1):
                    pathToDraw.move(to: CGPoint(x: point.x, y: point.y - gridNode.blockSize / 2))
                    pathToDraw.addLine(to: CGPoint(x: point2.x, y: point2.y + gridNode.blockSize / 2))
                default:
                    break
                }
                bridgesNode.path = pathToDraw
                bridgesNode.strokeColor = .yellow
                bridgesNode.glowWidth = 3
                bridgesNode.name = bridgesNodeName(dir)
                gridNode.addChild(bridgesNode)
            }
            func removeIslandConnections(dir: Int, bridges: Int) {
                guard bridges > 0 else {return}
                removeNode(withName: bridgesNodeName(dir))
            }
            let (o1, o2) = (stateFrom[p], stateTo[p])
            guard case let .island(s1, b1) = o1, case let .island(s2, b2) = o2 else {continue}
            if info.bridges != IslandConnectionsGame.PUZ_UNKNOWN && s1 != s2 {
                removeIslandNumber()
                addIslandNumber(n: info.bridges, s: s2, point: point, nodeName: islandNumberNodeName)
            }
            for dir in [1, 2] {
                if b1[dir] != b2[dir] {
                    removeIslandConnections(dir: dir, bridges: b1[dir])
                    addIslandConnections(dir: dir, bridges: b2[dir])
                }
            }
        }
    }
}
