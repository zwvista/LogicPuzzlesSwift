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
        
        // addHint
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
                func addWater(s: AllowedObjectState) {
                    addImage(imageNamed: "sea", color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: waterNodeName)
                }
                func removeWater() { removeNode(withName: waterNodeName) }
                func addMarker() { addDotMarker(point: point, nodeName: markerNodeName) }
                func removeMarker() { removeNode(withName: markerNodeName) }
                func addForbidden() { addForbiddenMarker(point: point, nodeName: forbiddenNodeName) }
                func removeForbidden() { removeNode(withName: forbiddenNodeName) }
                func removeHint() { removeNode(withName: hintNodeName) }
                let (o1, o2) = (stateFrom[p], stateTo[p])
                guard String(describing: o1) != String(describing: o2) else {continue}
                switch o1 {
                case .forbidden:
                    removeForbidden()
                case .water:
                    removeWater()
                case .hint:
                    removeHint()
                case .marker:
                    removeMarker()
                default:
                    break
                }
                switch o2 {
                case .forbidden:
                    addForbidden()
                case let .water(s):
                    addWater(s: s)
                case let .hint(id, s):
                    addHint(p: p, ch: id, s: s)
                case .marker:
                    addMarker()
                default:
                    break
                }
            }
        }
    }
}
