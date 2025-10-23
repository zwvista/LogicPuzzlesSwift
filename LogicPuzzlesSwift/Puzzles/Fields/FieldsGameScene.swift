//
//  FieldsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class FieldsGameScene: GameScene<FieldsGameState> {
    var gridNode: FieldsGridNode {
        get { getGridNode() as! FieldsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addField(isM: Bool, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        addImage(imageNamed: isM ? "meadow_background" : "soil", color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: FieldsGameState, skView: SKView) {
        let game = game as! FieldsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: FieldsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addHint
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let fieldNodeName = "field" + nodeNameSuffix
                let o = state[p]
                guard o != .empty else {continue}
                addField(isM: o == .meadow, s: state.pos2state[p] ?? .normal, point: point, nodeName: fieldNodeName)
                addCircleMarker(color: .white, point: point, nodeName: "marker")
            }
        }
    }
    
    override func levelUpdated(from stateFrom: FieldsGameState, to stateTo: FieldsGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let fieldNodeName = "field" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p] ?? .normal, stateTo.pos2state[p] ?? .normal)
                guard o1 != o2 || s1 != s2 else {continue}
                if o1 != .empty { removeNode(withName: fieldNodeName) }
                if o2 != .empty { addField(isM: o2 == .meadow, s: s2, point: point, nodeName: fieldNodeName) }
            }
        }
    }
}
