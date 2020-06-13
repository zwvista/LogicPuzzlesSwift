//
//  MosaikGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class MosaikGameScene: GameScene<MosaikGameState> {
    var gridNode: MosaikGridNode {
        get {getGridNode() as! MosaikGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: MosaikGameState, skView: SKView) {
        let game = game as! MosaikGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: MosaikGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addHints
        for (p, n) in game.pos2hint {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: state.pos2state[p]!, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: MosaikGameState, to stateTo: MosaikGameState) {
        let markerOffset: CGFloat = 7.5
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let filledCellNodeName = "filledCell" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                func addHint2() { addHint(n: stateFrom.game.pos2hint[p]!, s: stateTo.pos2state[p]!, point: point, nodeName: hintNodeName) }
                func removeHint() { removeNode(withName: hintNodeName) }
                func addFilledCell() {
                    let filledCellNode = SKSpriteNode(color: .purple, size: coloredRectSize())
                    filledCellNode.position = point
                    filledCellNode.name = filledCellNodeName
                    gridNode.addChild(filledCellNode)
                }
                func removeFilledCell() { removeNode(withName: filledCellNodeName) }
                func addMarker() { addCircleMarker(color: .white, point: point, nodeName: markerNodeName) }
                func removeMarker() { removeNode(withName: markerNodeName) }
                let (o1, o2) = (stateFrom[p], stateTo[p])
                if o1 != o2 {
                    switch o1 {
                    case .filled:
                        removeFilledCell()
                    case .marker:
                        removeMarker()
                    default:
                        break
                    }
                    switch o2 {
                    case .filled:
                        let b = stateFrom.game.pos2hint[p] != nil
                        if b {removeHint()}
                        addFilledCell()
                        if b {addHint2()}
                    case .marker:
                        addMarker()
                    default:
                        break
                    }
                }
                guard let s1 = stateFrom.pos2state[p], let s2 = stateTo.pos2state[p] else {continue}
                if s1 != s2 {
                    removeHint()
                    addHint2()
                }
            }
        }
    }
}
