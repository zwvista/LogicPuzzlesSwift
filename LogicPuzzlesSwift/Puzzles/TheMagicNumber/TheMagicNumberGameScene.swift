//
//  TheMagicNumberGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class TheMagicNumberGameScene: GameScene<TheMagicNumberGameState> {
    var gridNode: TheMagicNumberGridNode {
        get { getGridNode() as! TheMagicNumberGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addObject(o: TheMagicNumberObject, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        let imageName = switch o {
        case .fv1: "fv (1)"
        case .fv2: "fv (2)"
        case .fv3: "fv (3)"
        default: "fv (1)"
        }
        addImage(imageNamed: imageName, color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: TheMagicNumberGameState, skView: SKView) {
        let game = game as! TheMagicNumberGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: TheMagicNumberGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                let o = state[p]
                if o != .empty {
                    if game.shaded.contains(p) {
                        addBlock(color: .gray, point: point, nodeName: "block")
                    } else {
                        addCircleMarker(color: .white, point: point, nodeName: "marker")
                    }
                    addObject(o: o, s: state.pos2state[p]!, point: point, nodeName: tileNodeName)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: TheMagicNumberGameState, to stateTo: TheMagicNumberGameState) {
        let game = stateFrom.game
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
                if o2 != .empty { addObject(o: o2, s: s2!, point: point, nodeName: tileNodeName) }
            }
        }
    }
}
