//
//  BootyIslandGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class BootyIslandGameScene: GameScene<BootyIslandGameState> {
    var gridNode: BootyIslandGridNode {
        get { getGridNode() as! BootyIslandGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: BootyIslandGameState, skView: SKView) {
        let game = game as! BootyIslandGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: BootyIslandGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addHints
        for (p, n) in game.pos2hint {
            guard case let .hint(state: s) = state[p] else {continue}
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: s, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: BootyIslandGameState, to stateTo: BootyIslandGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let treasureNodeName = "treasure" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                func removeHint() { removeNode(withName: hintNodeName) }
                func addTreasure(s: AllowedObjectState) {
                    addImage(imageNamed: "delete2", color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: treasureNodeName)
                }
                func removeTreasure() { removeNode(withName: treasureNodeName) }
                func addMarker() { addCircleMarker(color: .white, point: point, nodeName: markerNodeName) }
                func removeMarker() { removeNode(withName: markerNodeName) }
                func addForbidden() { addForbiddenMarker(point: point, nodeName: forbiddenNodeName) }
                func removeForbidden() { removeNode(withName: forbiddenNodeName) }
                let (ot1, ot2) = (stateFrom[r, c], stateTo[r, c])
                guard String(describing: ot1) != String(describing: ot2) else {continue}
                switch ot1 {
                case .forbidden:
                    removeForbidden()
                case .treasure:
                    removeTreasure()
                case .marker:
                    removeMarker()
                case .hint:
                    removeHint()
                default:
                    break
                }
                switch ot2 {
                case .forbidden:
                    addForbidden()
                case let .treasure(s):
                    addTreasure(s: s)
                case .marker:
                    addMarker()
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
