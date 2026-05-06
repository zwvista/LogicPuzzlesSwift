//
//  HedgeMazeGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class HedgeMazeGameScene: GameScene<HedgeMazeGameState> {
    var gridNode: HedgeMazeGridNode {
        get { getGridNode() as! HedgeMazeGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addObject(o: HedgeMazeObject, point: CGPoint, nodeName: String) {
        let imageName = switch o {
        case .gate: "gates"
        case .step: "footstep"
        case .fountain: "fountain"
        case .hedge: "forest_lighter"
        default: ""
        }
        addImage(imageNamed: imageName, color: .red, colorBlendFactor: 0.0, point: point, nodeName: nodeName)
    }
    
    func addLines(game: HedgeMazeGame) {
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
    
    func addInvalid2x2(state: HedgeMazeGameState) {
        for p in state.invalid2x2Squares {
            let point = gridNode.cornerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            addDotMarker2(color: .red, point: point, nodeName: "invalid2x2")
        }
    }

    override func levelInitialized(_ game: AnyObject, state: HedgeMazeGameState, skView: SKView) {
        let game = game as! HedgeMazeGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: HedgeMazeGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        addLines(game: game)

        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                let o = state[p]
                guard o != .empty else {continue}
                addObject(o: o, point: point, nodeName: tileNodeName)
            }
        }
        addInvalid2x2(state: state)
    }
    
    override func levelUpdated(from stateFrom: HedgeMazeGameState, to stateTo: HedgeMazeGameState) {
        let game = stateFrom.game
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                guard o1 != o2 else {continue}
                if o1 != .empty { removeNode(withName: tileNodeName) }
                switch o2 {
                case .empty:
                    break
                case .marker:
                    addDotMarker(point: point, nodeName: tileNodeName)
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: tileNodeName)
                default:
                    addObject(o: o2, point: point, nodeName: tileNodeName)
                }
            }
        }

        removeNode(withName: "line")
        addLines(game: game)

        removeNode(withName: "invalid2x2")
        addInvalid2x2(state: stateTo)
    }
}
