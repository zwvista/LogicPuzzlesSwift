//
//  CloudsAndClearsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class CloudsAndClearsGameScene: GameScene<CloudsAndClearsGameState> {
    var gridNode: CloudsAndClearsGridNode {
        get { getGridNode() as! CloudsAndClearsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: CloudsAndClearsGameState, skView: SKView) {
        let game = game as! CloudsAndClearsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: CloudsAndClearsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
                
        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: state.pos2state[p]!, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: CloudsAndClearsGameState, to stateTo: CloudsAndClearsGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let markerNodeName = "marker" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let cloudNodeName = "cloud" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                if o1 != o2 {
                    switch o1 {
                    case .marker:
                        removeNode(withName: markerNodeName)
                    case .cloud:
                        removeNode(withName: cloudNodeName)
                    default:
                        break
                    }
                    switch o2 {
                    case .marker:
                        addDotMarker(point: point, nodeName: markerNodeName)
                    case .cloud:
                        addImage(imageNamed: "cloud", color: .red, colorBlendFactor: 0.0, point: point, nodeName: cloudNodeName)
                    default:
                        break
                    }
                }
                if s1 != s2 || s1 != nil && o1 != o2 {
                    removeNode(withName: hintNodeName)
                    addHint(n: stateFrom.game.pos2hint[p]!, s: s2!, point: point, nodeName: hintNodeName)
                }
            }
        }
    }
}
