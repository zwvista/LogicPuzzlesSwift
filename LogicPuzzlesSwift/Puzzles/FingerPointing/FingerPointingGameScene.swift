//
//  FingerPointingGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class FingerPointingGameScene: GameScene<FingerPointingGameState> {
    var gridNode: FingerPointingGridNode {
        get { getGridNode() as! FingerPointingGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: FingerPointingGameState, skView: SKView) {
        let game = game as! FingerPointingGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: FingerPointingGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let hintNodeName = "hint" + nodeNameSuffix
                switch state[p] {
                case .block:
                    addBlock(color: .white, point: point, nodeName: "block")
                case .hint:
                    addHint(n: game.pos2hint[p]!, s: .normal, point: point, nodeName: hintNodeName)
                default:
                    break
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: FingerPointingGameState, to stateTo: FingerPointingGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let hintNodeName = "hint" + nodeNameSuffix
                let imageNodeName = "image" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                guard o1 != o2 || s1 != s2  else {continue}
                switch o1 {
                case .empty, .block:
                    break
                case .hint:
                    removeNode(withName: hintNodeName)
                default:
                    removeNode(withName: imageNodeName)
                }
                switch o2 {
                case .empty, .block:
                    break
                case .hint:
                    let n = stateTo.game.pos2hint[Position(r, c)]!
                    addHint(n: n, s: s2!, point: point, nodeName: hintNodeName)
                default:
                    addImage(imageNamed: "finger_" + (o2 == .up ? "up" : o2 == .right ? "right" : o2 == .down ? "down" : "left"), color: .red, colorBlendFactor: s2 == .normal ? 0.0 : 0.5, point: point, nodeName: imageNodeName)
                }
            }
        }
    }
}
