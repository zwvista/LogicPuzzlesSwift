//
//  HiddenCloudsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class HiddenCloudsGameScene: GameScene<HiddenCloudsGameState> {
    var gridNode: HiddenCloudsGridNode {
        get { getGridNode() as! HiddenCloudsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: HiddenCloudsGameState, skView: SKView) {
        let game = game as! HiddenCloudsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: HiddenCloudsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))

        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            let s = state.pos2state[p]!
            addHint(n: n, s: s, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: HiddenCloudsGameState, to stateTo: HiddenCloudsGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let cloudNodeName = "cloud" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                if String(describing: o1) != String(describing: o2) {
                    switch o1 {
                    case .cloud: removeNode(withName: cloudNodeName)
                    case .forbidden: removeNode(withName: forbiddenNodeName)
                    case .marker: removeNode(withName: markerNodeName)
                    default: break
                    }
                    switch o2 {
                    case .cloud(let s):
                        addImage(imageNamed: "cloud", color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: cloudNodeName)
                    case .forbidden:
                        addDotMarker2(color: .red, point: point, nodeName: forbiddenNodeName)
                    case .marker:
                        addDotMarker(point: point, nodeName: markerNodeName)
                    default:
                        break
                    }
                }
                guard s1 != s2 || s2 != nil && o2.toString() == "cloud" else {continue}
                removeNode(withName: hintNodeName)
                addHint(n: stateFrom.game.pos2hint[p]!, s: s2!, point: point, nodeName: hintNodeName)
            }
        }
    }
}
