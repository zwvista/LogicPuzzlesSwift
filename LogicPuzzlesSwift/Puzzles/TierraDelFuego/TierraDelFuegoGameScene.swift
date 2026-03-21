//
//  TierraDelFuegoGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class TierraDelFuegoGameScene: GameScene<TierraDelFuegoGameState> {
    var gridNode: TierraDelFuegoGridNode {
        get { getGridNode() as! TierraDelFuegoGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(p: Position, ch: Character, s: HintState) {
        let point = gridNode.centerPoint(p: p)
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addLabel(text: String(ch), fontColor: s == .complete ? .green : .white, point: point, nodeName: hintNodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: TierraDelFuegoGameState, skView: SKView) {
        let game = game as! TierraDelFuegoGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: TierraDelFuegoGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for (p, ch) in game.pos2hint {
            addHint(p: p, ch: ch, s: .normal)
        }
    }
    
    override func levelUpdated(from stateFrom: TierraDelFuegoGameState, to stateTo: TierraDelFuegoGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let waterNodeName = "water" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2stateHint[p], stateTo.pos2stateHint[p])
                let (s3, s4) = (stateFrom.pos2stateAllowed[p], stateTo.pos2stateAllowed[p])
                guard o1 != o2 || s1 != s2 || s3 != s4 else {continue}
                switch o1 {
                case .forbidden:
                    removeNode(withName: forbiddenNodeName)
                case .water:
                    removeNode(withName: waterNodeName)
                case .hint:
                    removeNode(withName: hintNodeName)
                case .marker:
                    removeNode(withName: markerNodeName)
                default:
                    break
                }
                switch o2 {
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                case .water:
                    addImage(imageNamed: "sea", color: .red, colorBlendFactor: s4 == .normal ? 0.0 : 0.5, point: point, nodeName: waterNodeName)
                case .hint:
                    let id = stateFrom.game.pos2hint[p]!
                    addHint(p: p, ch: id, s: s2!)
                case .marker:
                    addDotMarker(point: point, nodeName: markerNodeName)
                default:
                    break
                }
            }
        }
    }
}
