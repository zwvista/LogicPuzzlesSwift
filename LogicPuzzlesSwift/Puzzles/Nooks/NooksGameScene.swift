//
//  NooksGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class NooksGameScene: GameScene<NooksGameState> {
    var gridNode: NooksGridNode {
        get { getGridNode() as! NooksGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: NooksGameState, skView: SKView) {
        let game = game as! NooksGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: NooksGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))

        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addImage(imageNamed: "hide", color: .red, colorBlendFactor: 0.0, point: point, nodeName: "hide")
            addHint(n: n, s: state.pos2state[p]!, point: point, nodeName: hintNodeName)
        }
        for p in state.invalid2x2Squares {
            let point = gridNode.cornerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let invalid2x2NodeName = "invalid2x2" + nodeNameSuffix
            addDotMarker2(color: .red, point: point, nodeName: invalid2x2NodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: NooksGameState, to stateTo: NooksGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let hedgeNodeName = "hedge" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let invalid2x2NodeName = "invalid2x2" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                if o1 != o2 || s1 != s2 {
                    switch o1 {
                    case .hedge:
                        removeNode(withName: hedgeNodeName)
                    case .hint:
                        removeNode(withName: hintNodeName)
                    case .marker:
                        removeNode(withName: markerNodeName)
                    default:
                        break
                    }
                    switch o2 {
                    case .hedge:
                        addImage(imageNamed: "forest_lighter", color: .red, colorBlendFactor: 0.0, point: point, nodeName: hedgeNodeName)
                    case .hint:
                        addHint(n: stateFrom.game.pos2hint[p]!, s: s2!, point: point, nodeName: hintNodeName)
                    case .marker:
                        addDotMarker(point: point, nodeName: markerNodeName)
                    default:
                        break
                    }
                }
                let (b1, b2) = (stateFrom.invalid2x2Squares.contains(p), stateTo.invalid2x2Squares.contains(p))
                if b1 != b2 {
                    let point = gridNode.cornerPoint(p: p)
                    if b1 { removeNode(withName: invalid2x2NodeName) }
                    if b2 { addDotMarker2(color: .red, point: point, nodeName: invalid2x2NodeName) }
                }
            }
        }
    }
}
