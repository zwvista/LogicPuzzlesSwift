//
//  ArchipelagoGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class ArchipelagoGameScene: GameScene<ArchipelagoGameState> {
    var gridNode: ArchipelagoGridNode {
        get { getGridNode() as! ArchipelagoGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(p: Position, n: Int, s: HintState) {
        let point = gridNode.centerPoint(p: p)
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addLabel(text: n == -1 ? "?" : String(n), fontColor: s == .complete ? .green : .white, point: point, nodeName: hintNodeName, sampleText: "10")
    }

    override func levelInitialized(_ game: AnyObject, state: ArchipelagoGameState, skView: SKView) {
        let game = game as! ArchipelagoGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: ArchipelagoGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addHint
        for (p, n) in game.pos2hint {
            addHint(p: p, n: n, s: .normal)
        }
    }
    
    override func levelUpdated(from stateFrom: ArchipelagoGameState, to stateTo: ArchipelagoGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let waterNodeName = "water" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let invalid2x2NodeName = "invalid2x2" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                guard String(describing: o1) != String(describing: o2) else {continue}
                switch o1 {
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
                case .water:
                    addImage(imageNamed: "sea", color: .red, colorBlendFactor: 0.0, point: point, nodeName: waterNodeName)
                case let .hint(s):
                    addHint(p: p, n: stateFrom.game.pos2hint[p]!, s: s)
                case .marker:
                    addDotMarker(point: point, nodeName: markerNodeName)
                default:
                    break
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
