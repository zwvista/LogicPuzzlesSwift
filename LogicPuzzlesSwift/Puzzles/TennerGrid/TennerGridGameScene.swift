//
//  TennerGridGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class TennerGridGameScene: GameScene<TennerGridGameState> {
    var gridNode: TennerGridGridNode {
        get { getGridNode() as! TennerGridGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addNumber(n: Int, s: HintState, isFixed: Bool, point: CGPoint, nodeName: String) {
        guard n >= 0 else {return}
        addLabel(text: String(n), fontColor: s == .normal ? isFixed ? .gray : .white : s == .complete ? .green : .red, point: point, nodeName: nodeName, sampleText: "22")
    }
    
    override func levelInitialized(_ game: AnyObject, state: TennerGridGameState, skView: SKView) {
        let game = game as! TennerGridGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: TennerGridGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addNumbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let n = state.game[p]
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let numberNodeName = "number" + nodeNameSuffix
                addNumber(n: n, s: state.pos2state[p] ?? .normal, isFixed: game[r, c] != -1, point: point, nodeName: numberNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: TennerGridGameState, to stateTo: TennerGridGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let numberNodeName = "number" + nodeNameSuffix
                func removeNumber() { removeNode(withName: numberNodeName) }
                let (n1, n2) = (stateFrom[r, c], stateTo[r, c])
                let (s1, s2) = (stateFrom.pos2state[p] ?? .normal, stateTo.pos2state[p] ?? .normal)
                guard n1 != n2 || s1 != s2 else {continue}
                if (n1 != -1) { removeNumber() }
                if (n2 != -1) { addNumber(n: n2, s: s2, isFixed: stateFrom.game[r, c] != -1, point: point, nodeName: numberNodeName) }
            }
        }
    }
}
