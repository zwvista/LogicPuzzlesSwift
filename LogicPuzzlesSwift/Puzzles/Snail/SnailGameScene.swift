//
//  SnailGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class SnailGameScene: GameScene<SnailGameState> {
    var gridNode: SnailGridNode {
        get { getGridNode() as! SnailGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(p: Position) {
        let point = gridNode.gridPosition(p: p)
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addLabel(text: "123", fontColor: .red, point: point, nodeName: hintNodeName)
    }
    
    func addSnailMarker(p: Position) {
        let point = gridNode.gridPosition(p: p)
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let snailMarkerNodeName = "snailMarker" + nodeNameSuffix
        addCircleMarker(color: .green, point: point, nodeName: snailMarkerNodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: SnailGameState, skView: SKView) {
        let game = game as! SnailGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols + 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: SnailGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols + 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows + 1) / 2 + offset))
        
        // add Snail Path
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path: pathToDraw)
        var point = gridNode.gridPosition(p: game.snailPathLine[0])
        pathToDraw.move(to: CGPoint(x: point.x - blockSize / 2, y: point.y + blockSize / 2))
        for i in 1..<game.snailPathLine.count {
            point = gridNode.gridPosition(p: game.snailPathLine[i])
            pathToDraw.addLine(to: CGPoint(x: point.x - blockSize / 2, y: point.y + blockSize / 2))
        }
        lineNode.glowWidth = 8
        lineNode.path = pathToDraw
        lineNode.strokeColor = .yellow
        lineNode.name = "line"
        gridNode.addChild(lineNode)
        
        // add Characters
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let ch = game[p]
                guard ch != " " else {continue}
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let charNodeName = "char" + nodeNameSuffix
                addLabel(text: String(ch), fontColor: .gray, point: point, nodeName: charNodeName)
                if state.pos2state[p] == .complete { addSnailMarker(p: p) }
            }
        }
        
        for r in 0..<game.rows {
            let p = Position(r, game.cols)
            if state.row2state[r] == .error { addHint(p: p) }
        }
        for c in 0..<game.cols {
            let p = Position(game.rows, c)
            if state.col2state[c] == .error { addHint(p: p) }
        }
    }
    
    override func levelUpdated(from stateFrom: SnailGameState, to stateTo: SnailGameState) {
        func removeHint(p: Position) {
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            removeNode(withName: hintNodeName)
        }
        for r in 0..<stateFrom.rows {
            let p = Position(r, stateFrom.cols)
            if stateFrom.row2state[r] != stateTo.row2state[r] {
                if stateFrom.row2state[r] == .error { removeHint(p: p) }
                if stateTo.row2state[r] == .error { addHint(p: p) }
            }
        }
        for c in 0..<stateFrom.cols {
            let p = Position(stateFrom.rows, c)
            if stateFrom.col2state[c] != stateTo.col2state[c] {
                if stateFrom.col2state[c] == .error { removeHint(p: p) }
                if stateTo.col2state[c] == .error { addHint(p: p) }
            }
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let charNodeName = "char" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let snailMarkerNodeName = "snailMarker" + nodeNameSuffix
                func addMarker() { addDotMarker(point: point, nodeName: markerNodeName) }
                func removeMarker() { removeNode(withName: markerNodeName) }
                func removeSnailMarker() { removeNode(withName: snailMarkerNodeName) }
                let (ch1, ch2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                if ch1 != ch2 {
                    if ch1 == "." {
                        removeMarker()
                    } else if (ch1 != " ") {
                        removeNode(withName: charNodeName)
                    }
                    if ch2 == "." {
                        addMarker()
                    } else if (ch2 != " ") {
                        addLabel(text: String(ch2), fontColor: .white, point: point, nodeName: charNodeName)
                    }
                }
                if s1 != s2 {
                    if s1 == .complete { removeSnailMarker() }
                    if s2 == .complete { addSnailMarker(p: p) }
                }
            }
        }
    }
}
