//
//  CulturedBranchesGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class CulturedBranchesGameScene: GameScene<CulturedBranchesGameState> {
    var gridNode: CulturedBranchesGridNode {
        get { getGridNode() as! CulturedBranchesGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(ch: Character, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(ch), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: CulturedBranchesGameState, skView: SKView) {
        let game = game as! CulturedBranchesGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: CulturedBranchesGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for (p, ch) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(ch: ch, s: state.pos2state[p]!, point: point, nodeName: hintNodeName)
        }
    }

    override func levelUpdated(from stateFrom: CulturedBranchesGameState, to stateTo: CulturedBranchesGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let branchNodeName = "branch" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                guard o1 != o2 || s1 != s2 else {continue}
                switch o1 {
                case .up, .right, .down, .left, .horizontal, .vertical:
                    removeNode(withName: branchNodeName)
                case .hint:
                    removeNode(withName: hintNodeName)
                default:
                    break
                }
                switch o2 {
                case .up, .right, .down, .left, .horizontal, .vertical:
                    addImage(imageNamed: "branch_" + String(describing: o2), color: .red, colorBlendFactor: 0.0, point: point, nodeName: branchNodeName)
                case .hint:
                    addHint(ch: stateFrom.game.pos2hint[p]!, s: s2!, point: point, nodeName: hintNodeName)
                default:
                    break
                }
            }
        }
    }
}
