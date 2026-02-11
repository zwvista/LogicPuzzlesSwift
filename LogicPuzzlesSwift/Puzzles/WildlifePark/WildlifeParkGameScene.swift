//
//  WildlifeParkGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class WildlifeParkGameScene: GameScene<WildlifeParkGameState> {
    var gridNode: WildlifeParkGridNode {
        get { getGridNode() as! WildlifeParkGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    override func levelInitialized(_ game: AnyObject, state: WildlifeParkGameState, skView: SKView) {
        let game = game as! WildlifeParkGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: WildlifeParkGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset))
        
        for p in game.posts {
            let point = gridNode.cornerPoint(p: p)
            addDotMarker2(color: .white, point: point, nodeName: "post")
        }
        
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                if game[r, c][1] == .line { addHorzLine(objType: .line, color: .white, point: point, nodeName: "line") }
                if game[r, c][2] == .line { addVertLine(objType: .line, color: .white, point: point, nodeName: "line") }
                guard let n = (game.animals.indices.first { game.animals[$0].contains(p) }) else {continue}
                let imageName = [
                    "bull",
                    "camel",
                    "chick",
                    "crab",
                    "elephant",
                    "fox",
                    "giraffe",
                    "hedgehog",
                    "hippopotamus",
                    "kangaroo",
                    "koala",
                    "lemur",
                    "lion",
                    "monkey",
                    "squirrel",
                    "swan",
                    "toucan",
                    "turtle",
                    "tiger",
                    "whale",
                    "zebra",
                ][n]
                addImage(imageNamed: imageName, color: .red, colorBlendFactor: 0.0, point: point, nodeName: "animal")
            }
        }
    }
    
    override func levelUpdated(from stateFrom: WildlifeParkGameState, to stateTo: WildlifeParkGameState) {
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
    }
}
