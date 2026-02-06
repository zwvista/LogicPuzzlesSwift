//
//  CrosstownTrafficGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class CrosstownTrafficGameScene: GameScene<CrosstownTrafficGameState> {
    var gridNode: CrosstownTrafficGridNode {
        get { getGridNode() as! CrosstownTrafficGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: CrosstownTrafficGameState, skView: SKView) {
        let game = game as! CrosstownTrafficGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: CrosstownTrafficGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Numbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let n = game.pos2hint[p]
                guard let n else {continue}
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let tileNodeName = "tile" + nodeNameSuffix
                addHint(n: n, s: .normal, point: point, nodeName: tileNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: CrosstownTrafficGameState, to stateTo: CrosstownTrafficGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                guard o1 != o2 || s1 != s2 else {continue}
                if o1 != .empty { removeNode(withName: tileNodeName) }
                switch o2 {
                case .empty:
                    break
                case .hint:
                    addHint(n: stateFrom.game.pos2hint[p]!, s: s2!, point: point, nodeName: tileNodeName)
                case .marker:
                    addDotMarker(point: point, nodeName: tileNodeName)
                default:
                    addImage(imageNamed: "road_\(String(describing: o2))", color: .red, colorBlendFactor: 0.0, point: point, nodeName: tileNodeName)
                }
            }
        }
    }
}
