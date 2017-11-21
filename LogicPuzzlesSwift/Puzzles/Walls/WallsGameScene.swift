//
//  WallsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class WallsGameScene: GameScene<WallsGameState> {
    var gridNode: WallsGridNode {
        get {return getGridNode() as! WallsGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: WallsGameState, skView: SKView) {
        let game = game as! WallsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: WallsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        for (p, n) in game.pos2hint {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: .normal, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: WallsGameState, to stateTo: WallsGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let horzNodeName = "horz" + nodeNameSuffix
                let vertNodeName = "vert" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                func addWall(isHorz: Bool) {
                    addImage(imageNamed: "tree", color: .red, colorBlendFactor: 0.0, point: point, nodeName: isHorz ? horzNodeName : vertNodeName,
                        zRotation: isHorz ? CGFloat(Double.pi / 2) : 0.0)
                }
                let (o1, o2) = (stateFrom[p], stateTo[p])
                guard String(describing: o1) != String(describing: o2) else {continue}
                switch o1 {
                case .hint:
                    removeNode(withName: hintNodeName)
                case .horz:
                    removeNode(withName: horzNodeName)
                case .vert:
                    removeNode(withName: vertNodeName)
                default:
                    break
                }
                switch o2 {
                case let .hint(n, s):
                    addHint(n: n, s: s, point: point, nodeName: hintNodeName)
                case .horz:
                    addWall(isHorz: true)
                case .vert:
                    addWall(isHorz: false)
                default:
                    break
                }
            }
        }
    }
}
