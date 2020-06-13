//
//  CarpentersWallGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class CarpentersWallGameScene: GameScene<CarpentersWallGameState> {
    var gridNode: CarpentersWallGridNode {
        get {getGridNode() as! CarpentersWallGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addHint(text: String, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: text, fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: CarpentersWallGameState, skView: SKView) {
        let game = game as! CarpentersWallGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: CarpentersWallGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let hintNodeName = "hint" + nodeNameSuffix
                switch state[p] {
                case let .corner(n, s):
                    addCircleMarker(color: .white, point: point, nodeName: "marker")
                    addHint(text: n == 0 ? "?" : String(n), s: s, point: point, nodeName: hintNodeName)
                case let .left(s):
                    addHint(text: "<", s: s, point: point, nodeName: hintNodeName)
                case let .up(s):
                    addHint(text: "^", s: s, point: point, nodeName: hintNodeName)
                case let .right(s):
                    addHint(text: ">", s: s, point: point, nodeName: hintNodeName)
                case let .down(s):
                    addHint(text: "v", s: s, point: point, nodeName: hintNodeName)
                default:
                    break
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: CarpentersWallGameState, to stateTo: CarpentersWallGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let point = gridNode.gridPosition(p: Position(r, c))
                let nodeNameSuffix = "-\(r)-\(c)"
                let wallNodeName = "wall" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let (ot1, ot2) = (stateFrom[r, c], stateTo[r, c])
                guard String(describing: ot1) != String(describing: ot2) else {continue}
                switch ot1 {
                case .wall:
                    removeNode(withName: wallNodeName)
                case .marker:
                    removeNode(withName: markerNodeName)
                case .corner, .left, .right, .up, .down:
                    removeNode(withName: hintNodeName)
                default:
                    break
                }
                switch ot2 {
                case .wall:
                    let wallNode = SKSpriteNode(color: .white, size: coloredRectSize())
                    wallNode.position = point
                    wallNode.name = wallNodeName
                    gridNode.addChild(wallNode)
                case .marker:
                    addDotMarker(point: point, nodeName: markerNodeName)
                case let .corner(n, s):
                    addHint(text: n == 0 ? "?" : String(n), s: s, point: point, nodeName: hintNodeName)
                case let .left(s):
                    addHint(text: "<", s: s, point: point, nodeName: hintNodeName)
                case let .up(s):
                    addHint(text: "^", s: s, point: point, nodeName: hintNodeName)
                case let .right(s):
                    addHint(text: ">", s: s, point: point, nodeName: hintNodeName)
                case let .down(s):
                    addHint(text: "v", s: s, point: point, nodeName: hintNodeName)
                default:
                    break
                }
            }
        }
    }
}
