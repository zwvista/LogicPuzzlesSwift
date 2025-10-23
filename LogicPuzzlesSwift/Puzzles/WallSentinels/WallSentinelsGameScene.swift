//
//  WallSentinelsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class WallSentinelsGameScene: GameScene<WallSentinelsGameState> {
    var gridNode: WallSentinelsGridNode {
        get { getGridNode() as! WallSentinelsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addWall(point: CGPoint, nodeName: String) {
        let wallNode = SKSpriteNode(color: .purple, size: coloredRectSize())
        wallNode.position = point
        wallNode.name = nodeName
        gridNode.addChild(wallNode)
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: WallSentinelsGameState, skView: SKView) {
        let game = game as! WallSentinelsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: WallSentinelsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addHints
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let hintNodeName = "hint" + nodeNameSuffix
                switch state[p] {
                case let .hintLand(n, s):
                    addHint(n: n, s: s, point: point, nodeName: hintNodeName)
                case let .hintWall(n, s):
                    addWall(point: point, nodeName: "wall")
                    addHint(n: n, s: s, point: point, nodeName: hintNodeName)
                default:
                    break
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: WallSentinelsGameState, to stateTo: WallSentinelsGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPoint(p: p)
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
                case .hintLand, .hintWall:
                    removeNode(withName: hintNodeName)
                default:
                    break
                }
                switch ot2 {
                case .wall:
                    addWall(point: point, nodeName: wallNodeName)
                case .marker:
                    addDotMarker(point: point, nodeName: markerNodeName)
                case let .hintLand(n, s):
                    addHint(n: n, s: s, point: point, nodeName: hintNodeName)
                case let .hintWall(n, s):
                    addHint(n: n, s: s, point: point, nodeName: hintNodeName)
                default:
                    break
                }
            }
        }
    }
}
