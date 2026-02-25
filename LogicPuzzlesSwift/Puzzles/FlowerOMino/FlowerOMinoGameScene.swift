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
    let flowerSize = CGSize(width: 50, height: 50)
    
    func getRightFlowerPoint(p: Position) -> CGPoint {
        let offset: CGFloat = 0.5
        let x = CGFloat(p.col + 1) * gridNode.blockSize + offset
        let y = -((CGFloat(p.row) + CGFloat(0.5)) * gridNode.blockSize + offset)
        return CGPoint(x: x, y: y)
    }
    
    func getBottomFlowerPoint(p: Position) -> CGPoint {
        let offset: CGFloat = 0.5
        let x = (CGFloat(p.col) + CGFloat(0.5)) * gridNode.blockSize + offset
        let y = -(CGFloat(p.row + 1) * gridNode.blockSize + offset)
        return CGPoint(x: x, y: y)
    }
    
    override func levelInitialized(_ game: AnyObject, state: FlowerOMinoGameState, skView: SKView) {
        let game = game as! FlowerOMinoGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: FlowerOMinoGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset))
        
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let flower1NodeName = "flower1" + nodeNameSuffix
                let flower2NodeName = "flower2" + nodeNameSuffix
                let flower4NodeName = "flower4" + nodeNameSuffix
                if state[r, c][1] == .line { addHorzLine(objType: .line, color: .white, point: point, nodeName: "line") }
                if state[r, c][2] == .line { addVertLine(objType: .line, color: .white, point: point, nodeName: "line") }
                let o = game[p]
                if o == .hedge {
                    addImage(imageNamed: "forest_lighter", color: .red, colorBlendFactor: 0.0, point: point, nodeName: "hedge")
                }
                if o.hasCenter {
                    addImage(imageNamed: "flower_orange", color: .red, colorBlendFactor: 0.0, point: point, nodeName: flower1NodeName, size: flowerSize)
                }
                if o.hasRight {
                    let point2 = getRightFlowerPoint(p: p)
                    addImage(imageNamed: "flower_pink", color: .red, colorBlendFactor: 0.0, point: point2, nodeName: flower2NodeName, size: flowerSize)
                }
                if o.hasBottom {
                    let point4 = getBottomFlowerPoint(p: p)
                    addImage(imageNamed: "flower_purple", color: .red, colorBlendFactor: 0.0, point: point4, nodeName: flower4NodeName, size: flowerSize)
                }
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
                let b1 = stateFrom.gardens.contains { $0.contains(p) }
                let b2 = stateTo.gardens.contains { $0.contains(p) }
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                if b1 != b2 || s1 != s2 {
                    let gardenNodeName = "garden" + nodeNameSuffix
                    if b1 { removeNode(withName: gardenNodeName) }
                    if b2 { addImage(imageNamed: "meadow_background", color: .red, colorBlendFactor: s2 == .normal ? 0.0 : 0.5, point: point, nodeName: gardenNodeName) }
                }
            }
        }
    }
}
