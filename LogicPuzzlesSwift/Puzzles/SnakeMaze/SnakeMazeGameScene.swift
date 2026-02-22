//
//  SnakeMazeGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class SnakeMazeGameScene: GameScene<SnakeMazeGameState> {
    var gridNode: SnakeMazeGridNode {
        get { getGridNode() as! SnakeMazeGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName, size: CGSize(width: gridNode.blockSize / 2, height: gridNode.blockSize / 2))
    }
    
    func getCenterPoint(p: Position, dir: Int) -> CGPoint {
        let offset: CGFloat = 0.5
        let x = switch dir {
        case 0: (CGFloat(p.col) + CGFloat(0.5)) * gridNode.blockSize + offset
        case 1: (CGFloat(p.col) + CGFloat(0.75)) * gridNode.blockSize + offset
        case 2: (CGFloat(p.col) + CGFloat(0.5)) * gridNode.blockSize + offset
        default: (CGFloat(p.col) + CGFloat(0.25)) * gridNode.blockSize + offset
        }
        let y = switch dir {
        case 0: -((CGFloat(p.row) + CGFloat(0.25)) * gridNode.blockSize + offset)
        case 1: -((CGFloat(p.row) + CGFloat(0.5)) * gridNode.blockSize + offset)
        case 2: -((CGFloat(p.row) + CGFloat(0.75)) * gridNode.blockSize + offset)
        default: -((CGFloat(p.row) + CGFloat(0.5)) * gridNode.blockSize + offset)
        }
        return CGPoint(x: x, y: y)
    }
    
    func getImageName(dir: Int) -> String {
        switch dir {
        case 0: "arrow_cyan_up"
        case 1: "arrow_cyan_right"
        case 2: "arrow_cyan_down"
        default: "arrow_cyan_left"
        }
    }

    override func levelInitialized(_ game: AnyObject, state: SnakeMazeGameState, skView: SKView) {
        let game = game as! SnakeMazeGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: SnakeMazeGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                switch state[p] {
                case .forbidden:
                    addDotMarker2(color: .red, point: point, nodeName: tileNodeName)
                case .hint:
                    let hint = game.pos2hint[p]!
                    let dir2 = hint.dir, dir1 = (dir2 + 2) % 4
                    let point = gridNode.centerPoint(p: p)
                    let point1 = getCenterPoint(p: p, dir: dir1)
                    addHint(n: hint.num, s: state.pos2stateHint[p]!, point: point1, nodeName: tileNodeName)
                    addImage(imageNamed: getImageName(dir: dir2), color: .red, colorBlendFactor: 0.0, point: point, nodeName: "arrow")
                default:
                    break
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: SnakeMazeGameState, to stateTo: SnakeMazeGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                let snakeNodeName = "snake" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2stateAllowed[p], stateTo.pos2stateAllowed[p])
                let (s3, s4) = (stateFrom.pos2stateHint[p], stateTo.pos2stateHint[p])
                let isSnake1 = stateFrom.snakes.contains { $0.contains(p) }
                let isSnake2 = stateTo.snakes.contains { $0.contains(p) }
                if o1 != o2 || s1 != s2 || s3 != s4 {
                    switch o1 {
                    case .empty:
                        break
                    default:
                        removeNode(withName: tileNodeName)
                        if isSnake1 { removeNode(withName: snakeNodeName) }
                    }
                    switch o2 {
                    case .forbidden:
                        addDotMarker2(color: .red, point: point, nodeName: tileNodeName)
                    case .marker:
                        addDotMarker(point: point, nodeName: tileNodeName)
                    case .hint:
                        let hint = stateFrom.game.pos2hint[p]!
                        let dir2 = hint.dir, dir1 = (dir2 + 2) % 4
                        let point1 = getCenterPoint(p: p, dir: dir1)
                        addHint(n: hint.num, s: s4!, point: point1, nodeName: tileNodeName)
                    default:
                        if isSnake2 {
                            addImage(imageNamed: "scales", color: .red, colorBlendFactor: s2 == .normal ? 0.0 : 0.5, point: point, nodeName: snakeNodeName)
                        }
                        if o2.isSnake {
                            addLabel(text: String(o2.value), fontColor: .white, point: point, nodeName: tileNodeName)
                        }
                    }
                }
            }
        }
    }
}
