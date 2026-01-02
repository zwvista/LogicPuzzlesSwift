//
//  BranchesGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class BranchesGameScene: GameScene<BranchesGameState> {
    var gridNode: BranchesGridNode {
        get { getGridNode() as! BranchesGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: BranchesGameState, skView: SKView) {
        let game = game as! BranchesGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: BranchesGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for (p, n) in game.pos2hint {
            guard case let .hint(state: s) = state[p] else {continue}
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: s, point: point, nodeName: hintNodeName)
        }
    }

    override func levelUpdated(from stateFrom: BranchesGameState, to stateTo: BranchesGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let branchNodeName = "branch" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                func addBranch(imageNamed: String) {
                    addImage(imageNamed: imageNamed, color: .red, colorBlendFactor: 0.0, point: point, nodeName: branchNodeName)
                }
                func removeBranch() { removeNode(withName: branchNodeName) }
                func removeHint() { removeNode(withName: hintNodeName) }
                let (ot1, ot2) = (stateFrom[r, c], stateTo[r, c])
                guard String(describing: ot1) != String(describing: ot2) else {continue}
                switch ot1 {
                case .up, .right, .down, .left, .horizontal, .vertical:
                    removeBranch()
                case .hint:
                    removeHint()
                default:
                    break
                }
                switch ot2 {
                case .up, .right, .down, .left, .horizontal, .vertical:
                    addBranch(imageNamed: "branch_" + ot2.toString())
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
