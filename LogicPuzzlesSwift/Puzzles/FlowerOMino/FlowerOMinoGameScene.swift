//
//  FlowerOMinoGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class FlowerOMinoGameScene: GameScene<FlowerOMinoGameState> {
    var gridNode: FlowerOMinoGridNode {
        get { getGridNode() as! FlowerOMinoGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addFlower(s: HintState, point: CGPoint, nodeName: String) {
        let flowerNode = SKShapeNode(circleOfRadius: gridNode.blockSize / 3)
        flowerNode.position = point
        flowerNode.name = nodeName
        flowerNode.strokeColor = s == .normal ? .white : s == .complete ? .green : .red
        flowerNode.glowWidth = 5.0
        flowerNode.fillColor = .gray
        gridNode.addChild(flowerNode)
    }
    
    override func levelInitialized(_ game: AnyObject, state: FlowerOMinoGameState, skView: SKView) {
        let game = game as! FlowerOMinoGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: FlowerOMinoGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset))
        
        for p in game.hedges {
            let point = gridNode.centerPoint(p: p)
            let hedgeNode = SKSpriteNode(color: .gray, size: coloredRectSize())
            hedgeNode.position = point
            hedgeNode.name = "hedge"
            gridNode.addChild(hedgeNode)
        }
        for p in game.flowers {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let flowerNodeName = "flower" + nodeNameSuffix
            addFlower(s: .normal, point: point, nodeName: flowerNodeName)
        }

        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                if state[r, c][1] == .line { addHorzLine(objType: .line, color: .white, point: point, nodeName: "line") }
                if state[r, c][2] == .line { addVertLine(objType: .line, color: .white, point: point, nodeName: "line") }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: FlowerOMinoGameState, to stateTo: FlowerOMinoGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let horzLineNodeName = "horzLine" + nodeNameSuffix
                let vertlineNodeName = "vertline" + nodeNameSuffix
                func removeHorzLine(objType: GridLineObject) {
                    if objType != .empty { removeNode(withName: horzLineNodeName) }
                }
                func removeVertLine(objType: GridLineObject) {
                    if objType != .empty { removeNode(withName: vertlineNodeName) }
                }
                var (o1, o2) = (stateFrom[p][1], stateTo[p][1])
                if o1 != o2 {
                    removeHorzLine(objType: o1)
                    addHorzLine(objType: o2, color: .yellow, point: point, nodeName: horzLineNodeName)
                }
                (o1, o2) = (stateFrom[p][2], stateTo[p][2])
                if o1 != o2 {
                    removeVertLine(objType: o1)
                    addVertLine(objType: o2, color: .yellow, point: point, nodeName: vertlineNodeName)
                }
            }
        }
        for p in stateFrom.game.flowers {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let flowerNodeName = "flower" + nodeNameSuffix
            let (s1, s2) = (stateFrom.pos2state[p]!, stateTo.pos2state[p]!)
            if s1 != s2 {
                removeNode(withName: flowerNodeName)
                addFlower(s: s2, point: point, nodeName: flowerNodeName)
            }
        }
    }
}
