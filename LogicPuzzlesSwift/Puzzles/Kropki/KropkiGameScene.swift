//
//  KropkiGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class KropkiGameScene: GameScene<KropkiGameState> {
    var gridNode: KropkiGridNode {
        get {return getGridNode() as! KropkiGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addHint(p: Position, isHorz: Bool, s: HintState, kh: KropkiHint) {
        var point = gridNode.gridPosition(p: p)
        if isHorz {
            point.x += gridNode.blockSize / 2
        } else {
            point.y -= gridNode.blockSize / 2
        }
        let nodeNameSuffix = "-\(p.row)-\(p.col)-" + (isHorz ? "h" : "v")
        let nodeName = "hint" + nodeNameSuffix
        let hintNode = SKShapeNode(circleOfRadius: gridNode.blockSize / 8)
        hintNode.position = point
        hintNode.name = nodeName
        hintNode.strokeColor = s == .normal ? .white : s == .complete ? .green : .red
        hintNode.fillColor = kh == .consecutive ? .white : .black
        hintNode.glowWidth = 4.0
        gridNode.addChild(hintNode)
    }

    override func levelInitialized(_ game: AnyObject, state: KropkiGameState, skView: SKView) {
        let game = game as! KropkiGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: KropkiGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addHint
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                for i in 0..<2 {
                    guard i == 0 && c != game.cols - 1 || i == 1 && r != game.rows - 1 else {continue}
                    let kh = game[r * 2 + i, c]
                    guard kh != .none else {continue}
                    addHint(p: Position(r, c), isHorz: i == 0, s: .normal, kh: kh)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: KropkiGameState, to stateTo: KropkiGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                let (n1, n2) = (stateFrom[r, c], stateTo[r, c])
                if n1 != n2 {
                    if n1 != 0 {removeNode(withName: numberNodeName)}
                    if n2 != 0 {addLabel(text: String(n2), fontColor: .white, point: point, nodeName: numberNodeName)}
                }
                for i in 0..<2 {
                    guard i == 0 && c != stateFrom.game.cols - 1 || i == 1 && r != stateFrom.game.rows - 1 else {continue}
                    let p2 = Position(r * 2 + i, c)
                    let nodeNameSuffix = "-\(p.row)-\(p.col)-" + (i == 0 ? "h" : "v")
                    let hintNodeName = "hint" + nodeNameSuffix
                    let kh = stateFrom.game[p2]
                    guard kh != .none else {continue}
                    let (s1, s2) = (stateFrom.pos2state[p2] ?? .normal, stateTo.pos2state[p2] ?? .normal)
                    if s1 != s2 {
                        removeNode(withName: hintNodeName)
                        addHint(p: Position(r, c), isHorz: i == 0, s: s2, kh: kh)
                    }
                }
            }
        }
    }
}
