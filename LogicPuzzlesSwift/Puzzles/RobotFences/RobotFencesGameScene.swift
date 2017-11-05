//
//  RobotFencesGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class RobotFencesGameScene: GameScene<RobotFencesGameState> {
    var gridNode: RobotFencesGridNode {
        get {return getGridNode() as! RobotFencesGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addNumber(n: String, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    func addHint(p: Position, info: RobotFencesInfo) {
        let point = gridNode.gridPosition(p: p)
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addNumber(n: String(info.nums), s: info.state, point: point, nodeName: hintNodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: RobotFencesGameState, skView: SKView) {
        let game = game as! RobotFencesGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols + 1)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: RobotFencesGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols + 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows + 1) / 2 + offset))
        
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path: pathToDraw)
        for r in 0..<game.rows + 1 {
            for c in 0..<game.cols + 1 {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                for dir in 1...2 {
                    guard game.dots[r, c][dir] == .line else {continue}
                    switch dir {
                    case 1:
                        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        pathToDraw.addLine(to: CGPoint(x: point.x + gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        lineNode.glowWidth = 8
                    case 2:
                        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        pathToDraw.addLine(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y - gridNode.blockSize / 2))
                        lineNode.glowWidth = 8
                    default:
                        break
                    }
                }
            }
        }
        lineNode.path = pathToDraw
        lineNode.strokeColor = .yellow
        lineNode.name = "line"
        gridNode.addChild(lineNode)

        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let n = game[p]
                guard n != 0 else {continue}
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                addLabel(text: String(n), fontColor: .gray, point: point, nodeName: numberNodeName)
            }
        }

        // addHints
        for r in 0..<game.rows {
            addHint(p: Position(r, game.cols), info: state.row2info[r])
        }
        for c in 0..<game.cols {
            addHint(p: Position(game.rows, c), info: state.col2info[c])
        }
    }
    
    override func levelUpdated(from stateFrom: RobotFencesGameState, to stateTo: RobotFencesGameState) {
        func removeHint(p: Position) {
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            removeNode(withName: hintNodeName)
        }
        for r in 0..<stateFrom.rows {
            let p = Position(r, stateFrom.cols)
            let (infoFrom, infoTo) = (stateFrom.row2info[r], stateTo.row2info[r])
            if  infoFrom.nums != infoTo.nums || infoFrom.state != infoTo.state {
                removeHint(p: p)
                addHint(p: p, info: infoTo)
            }
        }
        for c in 0..<stateFrom.cols {
            let p = Position(stateFrom.rows, c)
            let (infoFrom, infoTo) = (stateFrom.col2info[c], stateTo.col2info[c])
            if  infoFrom.nums != infoTo.nums || infoFrom.state != infoTo.state {
                removeHint(p: p)
                addHint(p: p, info: infoTo)
            }
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                guard stateFrom.game[p] == 0 else {continue}
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                let (n1, n2) = (stateFrom[p], stateTo[p])
                let i = stateFrom.game.pos2area[p]!
                let (s1, s2) = (stateFrom.area2info[i].state, stateTo.area2info[i].state)
                if n1 != n2 || s1 != s2 {
                    if n1 != 0 {removeNode(withName: numberNodeName)}
                    if n2 != 0 {addNumber(n: String(n2), s: s2, point: point, nodeName: numberNodeName)}
                }
            }
        }
    }
}
