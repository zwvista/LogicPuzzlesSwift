//
//  ChocolateGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class ChocolateGameScene: GameScene<ChocolateGameState> {
    var gridNode: ChocolateGridNode {
        get { getGridNode() as! ChocolateGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(p: Position, n: Int, s: HintState) {
        let point = gridNode.centerPoint(p: p)
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addLabel(text: String(n), fontColor: s == .complete ? .green : .white, point: point, nodeName: hintNodeName)
    }
    
    func addLines(game: ChocolateGame) {
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path: pathToDraw)
        for r in 0..<game.rows + 1 {
            for c in 0..<game.cols + 1 {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
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
        lineNode.name = "line"
        gridNode.addChild(lineNode)
    }

    override func levelInitialized(_ game: AnyObject, state: ChocolateGameState, skView: SKView) {
        let game = game as! ChocolateGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: ChocolateGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        addLines(game: game)
        
        // add Hints
        for (p, n) in game.pos2hint {
            addHint(p: p, n: n, s: state.pos2stateHint[p]!)
        }

        for r in 0..<state.rows {
            for c in 0..<state.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                guard state[p] == .forbidden else {continue}
                let nodeNameSuffix = "-\(r)-\(c)"
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: ChocolateGameState, to stateTo: ChocolateGameState) {
        let game = stateFrom.game
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let chocolateNodeName = "chocolate" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2stateHint[p], stateTo.pos2stateHint[p])
                let (s3, s4) = (stateFrom.pos2stateAllowed[p], stateTo.pos2stateAllowed[p])
                if o1 != o2 || s3 != s4 {
                    switch o1 {
                    case .forbidden:
                        removeNode(withName: forbiddenNodeName)
                    case .marker:
                        removeNode(withName: markerNodeName)
                    case .chocolate:
                        removeNode(withName: chocolateNodeName)
                    default:
                        break
                    }
                    switch o2 {
                    case .forbidden:
                        addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                    case .marker:
                        addDotMarker(point: point, nodeName: markerNodeName)
                    case .chocolate:
                        addImage(imageNamed: "chocolate_square", color: .red, colorBlendFactor: s4 == .normal ? 0.0 : 0.5, point: point, nodeName: chocolateNodeName)
                    default:
                        break
                    }
                }
                guard s1 != s2 || s2 != nil && o2 == .chocolate else {continue}
                removeNode(withName: hintNodeName)
                addHint(p: p, n: game.pos2hint[p]!, s: s2!)
            }
        }

        removeNode(withName: "line")
        addLines(game: game)
    }
}
