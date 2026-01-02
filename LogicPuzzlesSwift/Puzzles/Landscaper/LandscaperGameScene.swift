//
//  LandscaperGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class LandscaperGameScene: GameScene<LandscaperGameState> {
    var gridNode: LandscaperGridNode {
        get { getGridNode() as! LandscaperGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addToken(isT: Bool, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        addImage(imageNamed: isT ? "tree" : "flower_blue", color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: LandscaperGameState, skView: SKView) {
        let game = game as! LandscaperGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: LandscaperGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addHint
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tokenNodeName = "token" + nodeNameSuffix
                let o = state[p]
                guard o != .empty else {continue}
                addToken(isT: o == .tree, s: state.pos2state[p] ?? .normal, point: point, nodeName: tokenNodeName)
                addCircleMarker(color: .white, point: point, nodeName: "marker")
            }
        }
    }
    
    override func levelUpdated(from stateFrom: LandscaperGameState, to stateTo: LandscaperGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tokenNodeName = "token" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p] ?? .normal, stateTo.pos2state[p] ?? .normal)
                guard o1 != o2 || s1 != s2 else {continue}
                if o1 != .empty { removeNode(withName: tokenNodeName) }
                if o2 != .empty { addToken(isT: o2 == .tree, s: s2, point: point, nodeName: tokenNodeName) }
            }
        }
    }
}
