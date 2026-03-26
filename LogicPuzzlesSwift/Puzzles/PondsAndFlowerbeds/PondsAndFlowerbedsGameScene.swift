//
//  PondsAndFlowerbedsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class PondsAndFlowerbedsGameScene: GameScene<PondsAndFlowerbedsGameState> {
    var gridNode: PondsAndFlowerbedsGridNode {
        get { getGridNode() as! PondsAndFlowerbedsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addLines(game: PondsAndFlowerbedsGame) {
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                if game[p][1] == .line { addHorzLine(objType: .line, color: .white, point: point, nodeName: "line") }
                if game[p][2] == .line { addVertLine(objType: .line, color: .white, point: point, nodeName: "line") }
            }
        }
    }

    override func levelInitialized(_ game: AnyObject, state: PondsAndFlowerbedsGameState, skView: SKView) {
        let game = game as! PondsAndFlowerbedsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: PondsAndFlowerbedsGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset))
        
        for p in game.flowers {
            let point = gridNode.centerPoint(p: p)
            addImage(imageNamed: "flower_pink", color: .red, colorBlendFactor: 0.0, point: point, nodeName: "flower")
        }
        for p in game.hedges {
            let point = gridNode.centerPoint(p: p)
            addImage(imageNamed: "forest", color: .red, colorBlendFactor: 0.0, point: point, nodeName: "forest")
        }
        
        addLines(game: game)
    }
    
    override func levelUpdated(from stateFrom: PondsAndFlowerbedsGameState, to stateTo: PondsAndFlowerbedsGameState) {
        let game = stateFrom.game
        var rng = Set<Position>()
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let pondNodeName = "pond" + nodeNameSuffix
                let (b1, b2) = (stateFrom.ponds.contains { $0.contains(p) }, stateTo.ponds.contains { $0.contains(p) })
                if b1 != b2 {
                    if b1 { removeNode(withName: pondNodeName) }
                    if b2 {
                        addImage(imageNamed: "sea", color: .red, colorBlendFactor: 0.0, point: point, nodeName: pondNodeName)
                        for os in PondsAndFlowerbedsGame.offset3 {
                            rng.insert(p + os)
                        }
                    }
                }
            }
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let horzLineNodeName = "horzLine" + nodeNameSuffix
                let vertlineNodeName = "vertline" + nodeNameSuffix
                var (o1, o2) = (stateFrom[p][1], stateTo[p][1])
                if o1 != o2 || rng.contains(p) && game[p][1] != .line {
                    removeHorzLine(objType: o1, nodeName: horzLineNodeName)
                    addHorzLine(objType: o2, color: .yellow, point: point, nodeName: horzLineNodeName)
                }
                (o1, o2) = (stateFrom[p][2], stateTo[p][2])
                if o1 != o2 || rng.contains(p) && game[p][2] != .line {
                    removeVertLine(objType: o1, nodeName: vertlineNodeName)
                    addVertLine(objType: o2, color: .yellow, point: point, nodeName: vertlineNodeName)
                }
            }
        }

        removeNode(withName: "line")
        addLines(game: game)
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let invalid2x2NodeName = "invalid2x2" + nodeNameSuffix
                let (b3, b4) = (stateFrom.invalid2x2Squares.contains(p), stateTo.invalid2x2Squares.contains(p))
                if b3 != b4 {
                    let point = gridNode.cornerPoint(p: p)
                    if b3 { removeNode(withName: invalid2x2NodeName) }
                    if b4 { addDotMarker2(color: .red, point: point, nodeName: invalid2x2NodeName) }
                }
            }
        }
    }
}
