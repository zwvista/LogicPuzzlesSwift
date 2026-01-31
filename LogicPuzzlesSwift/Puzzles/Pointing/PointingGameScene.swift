//
//  PointingGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class PointingGameScene: GameScene<PointingGameState> {
    var gridNode: PointingGridNode {
        get { getGridNode() as! PointingGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addArrow(n: Int, isBW: Bool, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        addImage(imageNamed: getArrowImageName(n: n) + (isBW ? "_bw" : ""), color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: PointingGameState, skView: SKView) {
        let game = game as! PointingGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: PointingGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let arrowNodeName = "arrow" + nodeNameSuffix
                addArrow(n: game[p], isBW: !state.markedArrows.contains(p), s: state.nonPointingArrows.contains(p) ? .error : .normal, point: point, nodeName: arrowNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: PointingGameState, to stateTo: PointingGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let arrowNodeName = "arrow" + nodeNameSuffix
                let (b1, b2) = (stateFrom.markedArrows.contains(p), stateTo.markedArrows.contains(p))
                let (b3, b4) = (stateFrom.nonPointingArrows.contains(p), stateTo.nonPointingArrows.contains(p))
                if b1 != b2 || b3 != b4 {
                    removeNode(withName: arrowNodeName)
                    addArrow(n: stateFrom.game[p], isBW: !b2, s: b4 ? .error : .normal, point: point, nodeName: arrowNodeName)
                }
            }
        }
    }
}
