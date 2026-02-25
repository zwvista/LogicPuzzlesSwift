//
//  NurikabeGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class NurikabeGameScene: GameScene<NurikabeGameState> {
    var gridNode: NurikabeGridNode {
        get { getGridNode() as! NurikabeGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: NurikabeGameState, skView: SKView) {
        let game = game as! NurikabeGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: NurikabeGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: state.pos2state[p]!, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: NurikabeGameState, to stateTo: NurikabeGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let wallNodeName = "wall" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let invalid2x2NodeName = "invalid2x2" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                if o1 != o2 || s1 != s2 {
                    switch o1 {
                    case .hint:
                        removeNode(withName: hintNodeName)
                    case .marker:
                        removeNode(withName: markerNodeName)
                    case .wall:
                        removeNode(withName: wallNodeName)
                    default:
                        break
                    }
                    switch o2 {
                    case .hint:
                        addHint(n: stateFrom.game.pos2hint[p]!, s: s2!, point: point, nodeName: hintNodeName)
                    case .marker:
                        addDotMarker(point: point, nodeName: markerNodeName)
                    case .wall:
                        addBlock(color: .white, point: point, nodeName: wallNodeName)
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
