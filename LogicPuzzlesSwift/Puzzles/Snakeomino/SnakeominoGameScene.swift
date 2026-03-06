//
//  SnakeominoGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class SnakeominoGameScene: GameScene<SnakeominoGameState> {
    var gridNode: SnakeominoGridNode {
        get { getGridNode() as! SnakeominoGridNode }
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
    
    override func levelInitialized(_ game: AnyObject, state: SnakeominoGameState, skView: SKView) {
        let game = game as! SnakeominoGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: SnakeominoGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        for r in 0..<game.rows + 1 {
            for c in 0..<game.cols + 1 {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                func f(p2: Position) -> Int {
                    !game.isValid(p: p2) ? -1 : game[p2]
                }
                let o = f(p2: p)
                func g(p2: Position) -> Bool {
                    let o2 = f(p2: p2)
                    return o != o2 && (o == -1 || o2 == -1 || o != 0 && o2 != 0)
                }
                if g(p2: Position(r - 1, c)) { addHorzLine(objType: .line, color: .white, point: point, nodeName: "line") }
                if g(p2: Position(r, c - 1)) { addVertLine(objType: .line, color: .white, point: point, nodeName: "line") }
                guard r < game.rows && c < game.cols else {continue}
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                if o > 0 {
                    addLabel(text: String(o), fontColor: .gray, point: point, nodeName: numberNodeName)
                }
                guard let ch = game.pos2hint[p] else {continue}
                let hintNodeName = "hint" + nodeNameSuffix
                if ch == SnakeominoGame.PUZ_END {
                    addCircleMarker(color: .white, point: point, nodeName: hintNodeName)
                } else if ch == SnakeominoGame.PUZ_NOT_END {
                    addLabel(text: "X", fontColor: .gray, point: point, nodeName: numberNodeName)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: SnakeominoGameState, to stateTo: SnakeominoGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let horzLineNodeName = "horzLine" + nodeNameSuffix
                let vertlineNodeName = "vertline" + nodeNameSuffix
                func f(state: SnakeominoGameState, p2: Position) -> Bool {
                    let (o, o2) = (state[p], state[p2])
                    return o != o2 && o != 0 && o2 != 0
                }
                if r > 0 {
                    let p2 = Position(r - 1, c)
                    let (b1, b2) = (f(state: stateFrom, p2: p2), f(state: stateTo, p2: p2))
                    if b1 != b2 {
                        if b1 { removeNode(withName: horzLineNodeName) }
                        if b2 { addHorzLine(objType: .line, color: .yellow, point: point, nodeName: horzLineNodeName) }
                    }
                }
                if (c > 0) {
                    let p2 = Position(r, c - 1)
                    let (b1, b2) = (f(state: stateFrom, p2: p2), f(state: stateTo, p2: p2))
                    if b1 != b2 {
                        if b1 { removeNode(withName: vertlineNodeName) }
                        if b2 { addVertLine(objType: .line, color: .yellow, point: point, nodeName: vertlineNodeName) }
                    }
                }
                let numberNodeName = "number" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                if o1 != o2 {
                    if o1 > 0 { removeNode(withName: numberNodeName) }
                    if o2 > 0 { addLabel(text: String(o2), fontColor: .white, point: point, nodeName: numberNodeName) }
                }
            }
        }
    }
}
