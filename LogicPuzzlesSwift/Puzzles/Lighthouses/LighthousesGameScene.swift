//
//  LighthousesGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class LighthousesGameScene: GameScene<LighthousesGameState> {
    var gridNode: LighthousesGridNode {
        get { getGridNode() as! LighthousesGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: LighthousesGameState, skView: SKView) {
        let game = game as! LighthousesGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: LighthousesGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            let s = state.pos2stateHint[p]!
            addHint(n: n, s: s, point: point, nodeName: hintNodeName)
        }
        
        // addForbidden
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                guard state[p] == .forbidden else {continue}
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: LighthousesGameState, to stateTo: LighthousesGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let lighthouseNodeName = "lighthouse" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2stateHint[p], stateTo.pos2stateHint[p])
                let (s3, s4) = (stateFrom.pos2stateAllowed[p], stateTo.pos2stateAllowed[p])
                guard o1 != o2 || s1 != s2 || s3 != s4 else {continue}
                switch o1 {
                case .forbidden:
                    removeNode(withName: forbiddenNodeName)
                case .lighthouse:
                    removeNode(withName: lighthouseNodeName)
                case .marker:
                    removeNode(withName: markerNodeName)
                case .hint:
                    removeNode(withName: hintNodeName)
                default:
                    break
                }
                switch o2 {
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                case .lighthouse:
                    addImage(imageNamed: "lightbulb_on", color: .red, colorBlendFactor: s4 == .normal ? 0.0 : 0.5, point: point, nodeName: lighthouseNodeName)
                case .marker:
                    addCircleMarker(color: .white, point: point, nodeName: markerNodeName)
                case .hint:
                    let n = stateFrom.game.pos2hint[p]!
                    addHint(n: n, s: s2!, point: point, nodeName: hintNodeName)
                default:
                    break
                }
            }
        }
    }
}
