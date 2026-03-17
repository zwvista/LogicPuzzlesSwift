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
        get { getGridNode() as! CarpentersWallGridNode }
        set { setGridNode(gridNode: newValue) }
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
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let hintNodeName = "hint" + nodeNameSuffix
                let s = state.pos2state[p]
                switch state[p] {
                case .corner:
                    let n = game.pos2hint[p]!
                    addCircleMarker(color: .white, point: point, nodeName: "marker")
                    addHint(text: n == 0 ? "?" : String(n), s: s!, point: point, nodeName: hintNodeName)
                case .left:
                    addHint(text: "<", s: s!, point: point, nodeName: hintNodeName)
                case .up:
                    addHint(text: "^", s: s!, point: point, nodeName: hintNodeName)
                case .right:
                    addHint(text: ">", s: s!, point: point, nodeName: hintNodeName)
                case .down:
                    addHint(text: "v", s: s!, point: point, nodeName: hintNodeName)
                default:
                    break
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: CarpentersWallGameState, to stateTo: CarpentersWallGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let wallNodeName = "wall" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                guard o1 != o2 || s1 != s2 else {continue}
                switch o1 {
                case .wall:
                    removeNode(withName: wallNodeName)
                case .marker:
                    removeNode(withName: markerNodeName)
                case .corner, .left, .right, .up, .down:
                    removeNode(withName: hintNodeName)
                default:
                    break
                }
                switch o2 {
                case .wall:
                    addBlock(color: .white, point: point, nodeName: wallNodeName)
                case .marker:
                    addDotMarker(point: point, nodeName: markerNodeName)
                case .corner:
                    let n = stateFrom.game.pos2hint[p]!
                    addHint(text: n == 0 ? "?" : String(n), s: s2!, point: point, nodeName: hintNodeName)
                case .left:
                    addHint(text: "<", s: s2!, point: point, nodeName: hintNodeName)
                case .up:
                    addHint(text: "^", s: s2!, point: point, nodeName: hintNodeName)
                case .right:
                    addHint(text: ">", s: s2!, point: point, nodeName: hintNodeName)
                case .down:
                    addHint(text: "v", s: s2!, point: point, nodeName: hintNodeName)
                default:
                    break
                }
            }
        }
    }
}
