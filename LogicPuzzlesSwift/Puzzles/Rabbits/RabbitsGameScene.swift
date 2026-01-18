//
//  RabbitsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class RabbitsGameScene: GameScene<RabbitsGameState> {
    var gridNode: RabbitsGridNode {
        get { getGridNode() as! RabbitsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: RabbitsGameState, skView: SKView) {
        let game = game as! RabbitsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: RabbitsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for (p, n) in game.pos2hint {
            guard case let .hint(state: s) = state[p] else {continue}
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: s, point: point, nodeName: hintNodeName)
        }
        
        // addForbidden
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                guard case .forbidden = state[p] else {continue}
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: RabbitsGameState, to stateTo: RabbitsGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let rabbitNodeName = "rabbit" + nodeNameSuffix
                let treeNodeName = "tree" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let (ot1, ot2) = (stateFrom[r, c], stateTo[r, c])
                guard String(describing: ot1) != String(describing: ot2) else {continue}
                switch ot1 {
                case .forbidden:
                    removeNode(withName: forbiddenNodeName)
                case .rabbit:
                    removeNode(withName: rabbitNodeName)
                case .tree:
                    removeNode(withName: treeNodeName)
                case .marker:
                    removeNode(withName: markerNodeName)
                case .hint:
                    removeNode(withName: hintNodeName)
                default:
                    break
                }
                switch ot2 {
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                case let .rabbit(s):
                    addImage(imageNamed: "rabbit", color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: rabbitNodeName)
                case let .tree(s):
                    addImage(imageNamed: "tree", color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: treeNodeName)
                case .marker:
                    addCircleMarker(color: .white, point: point, nodeName: markerNodeName)
                case let .hint(s):
                    let n = stateTo.game.pos2hint[Position(r, c)]!
                    addHint(n: n, s: s, point: point, nodeName: hintNodeName)
                default:
                    break
                }
            }
        }
    }
}
