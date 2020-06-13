//
//  ParkLakesGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class ParkLakesGameScene: GameScene<ParkLakesGameState> {
    var gridNode: ParkLakesGridNode {
        get { getGridNode() as! ParkLakesGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(p: Position, n: Int, s: HintState) {
        let point = gridNode.gridPosition(p: p)
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addLabel(text: n == -1 ? "?" : String(n), fontColor: s == .complete ? .green : .white, point: point, nodeName: hintNodeName, sampleText: "10")
    }

    override func levelInitialized(_ game: AnyObject, state: ParkLakesGameState, skView: SKView) {
        let game = game as! ParkLakesGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: ParkLakesGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addHint
        for (p, n) in game.pos2hint {
            addHint(p: p, n: n, s: .normal)
        }
    }
    
    override func levelUpdated(from stateFrom: ParkLakesGameState, to stateTo: ParkLakesGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let treeNodeName = "tree" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                func addTree(s: AllowedObjectState) {
                    addImage(imageNamed: "tree", color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: treeNodeName)
                }
                func removeTree() { removeNode(withName: treeNodeName) }
                func addMarker() { addDotMarker(point: point, nodeName: markerNodeName) }
                func removeMarker() { removeNode(withName: markerNodeName) }
                func removeHint() { removeNode(withName: hintNodeName) }
                let (o1, o2) = (stateFrom[p], stateTo[p])
                guard String(describing: o1) != String(describing: o2) else {continue}
                switch o1 {
                case .tree:
                    removeTree()
                case .hint:
                    removeHint()
                case .marker:
                    removeMarker()
                default:
                    break
                }
                switch o2 {
                case let .tree(s):
                    addTree(s: s)
                case let .hint(n, s):
                    addHint(p: p, n: n, s: s)
                case .marker:
                    addMarker()
                default:
                    break
                }
            }
        }
    }
}
