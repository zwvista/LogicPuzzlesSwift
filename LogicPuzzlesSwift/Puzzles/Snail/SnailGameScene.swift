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
        get {return getGridNode() as! SnailGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addCharacter(ch: Character, s: HintState, isHint: Bool, point: CGPoint, nodeName: String) {
        addLabel(text: String(ch), fontColor: s == .normal ? isHint ? .gray : .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: SnailGameState, skView: SKView) {
        let game = game as! SnailGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: SnailGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path: pathToDraw)
        var point = gridNode.gridPosition(p: game.snailPathLine[0])
        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
        for i in 1..<game.snailPathLine.count {
            point = gridNode.gridPosition(p: game.snailPathLine[i])
            pathToDraw.addLine(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
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
                let ch = state[p]
                guard ch != " " else {continue}
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let charNodeName = "char" + nodeNameSuffix
                addCharacter(ch: ch, s: .normal, isHint: !game.isValid(p: p), point: point, nodeName: charNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: SnailGameState, to stateTo: SnailGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let charNodeName = "char" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                func removeCharacter() { removeNode(withName: charNodeName) }
                func addMarker() { addDotMarker(point: point, nodeName: markerNodeName) }
                func removeMarker() { removeNode(withName: markerNodeName) }
                let (ch1, ch2) = (stateFrom[r, c], stateTo[r, c])
                guard ch1 != ch2 else {continue}
                if ch1 == "." {
                    removeMarker()
                } else if (ch1 != " ") {
                    removeCharacter()
                }
                if ch2 == "." {
                    addMarker()
                } else if (ch2 != " ") {
                    addCharacter(ch: ch2, s: .normal, isHint: !stateFrom.game.isValid(p: p), point: point, nodeName: charNodeName)
                }
            }
        }
    }
}
