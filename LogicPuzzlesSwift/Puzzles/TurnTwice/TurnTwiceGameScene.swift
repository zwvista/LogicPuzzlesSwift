//
//  TurnTwiceGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class TurnTwiceGameScene: GameScene<TurnTwiceGameState> {
    var gridNode: TurnTwiceGridNode {
        get { getGridNode() as! TurnTwiceGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addsignpost(s: AllowedObjectState, point: CGPoint, nodeName: String) {
        addImage(imageNamed: "signpost", color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: TurnTwiceGameState, skView: SKView) {
        let game = game as! TurnTwiceGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: TurnTwiceGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for p in game.signposts {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let signpostNodeName = "signpost" + nodeNameSuffix
            let s = state.pos2state[p]!
            addsignpost(s: s, point: point, nodeName: signpostNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: TurnTwiceGameState, to stateTo: TurnTwiceGameState) {
        let game = stateFrom.game
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let signpostNodeName = "signpost" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let wallNodeName = "wall" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                guard o1 != o2 || s1 != s2 else {continue}
                switch o1 {
                case .forbidden:
                    removeNode(withName: forbiddenNodeName)
                case .marker:
                    removeNode(withName: markerNodeName)
                case .signpost:
                    removeNode(withName: signpostNodeName)
                case .wall:
                    removeNode(withName: wallNodeName)
                default:
                    break
                }
                switch o2 {
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                case .marker:
                    addDotMarker(point: point, nodeName: markerNodeName)
                case .signpost:
                    addsignpost(s: s2!, point: point, nodeName: signpostNodeName)
                case .wall:
                    addImage(imageNamed: "tower_wall", color: .red, colorBlendFactor: s2 == .normal ? 0.0 : 0.5, point: point, nodeName: wallNodeName)
                default:
                    break
                }
            }
        }
    }
}
