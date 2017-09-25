//
//  KakurasuGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class KakurasuGameScene: GameScene<KakurasuGameState> {
    var gridNode: KakurasuGridNode {
        get {return getGridNode() as! KakurasuGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addCloud(color: SKColor, point: CGPoint, nodeName: String) {
        let cloudNode = SKSpriteNode(color: color, size: coloredRectSize())
        cloudNode.position = point
        cloudNode.name = nodeName
        gridNode.addChild(cloudNode)
    }
    
    func addHint(p: Position, n: Int, s: HintState) {
        let point = gridNode.gridPosition(p: p)
        guard n >= 0 else {return}
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addHintNumber(n: n, s: s, point: point, nodeName: hintNodeName)
    }
    
    func addHintNumber(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: KakurasuGameState, skView: SKView) {
        let game = game as! KakurasuGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: KakurasuGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hint
        for r in 1..<game.rows - 1 {
            for i in 0..<2 {
                let p = Position(r, i == 0 ? 0 : game.cols - 1)
                let n = state.game.row2hint[r * 2 + i]
                addHint(p: p, n: n, s: state.row2state[r * 2 + i])
            }
        }
        for c in 1..<game.cols - 1 {
            for i in 0..<2 {
                let p = Position(i == 0 ? 0 : game.rows - 1, c)
                let n = state.game.col2hint[c * 2 + i]
                addHint(p: p, n: n, s: state.col2state[c * 2 + i])
            }
        }
    }
    
    override func levelUpdated(from stateFrom: KakurasuGameState, to stateTo: KakurasuGameState) {
        func removeHint(p: Position) {
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            removeNode(withName: hintNodeName)
        }
        for r in 1..<stateFrom.rows - 1 {
            let p = Position(r, 0)
            let n = stateFrom.game.row2hint[r * 2]
            if stateFrom.row2state[r * 2] != stateTo.row2state[r * 2] {
                removeHint(p: p)
                addHint(p: p, n: n, s: stateTo.row2state[r * 2])
            }
        }
        for c in 1..<stateFrom.cols - 1 {
            let p = Position(0, c)
            let n = stateFrom.game.col2hint[c * 2]
            if stateFrom.col2state[c * 2] != stateTo.col2state[c * 2] {
                removeHint(p: p)
                addHint(p: p, n: n, s: stateTo.col2state[c * 2])
            }
        }
        for r in 1..<stateFrom.rows - 1 {
            for c in 1..<stateFrom.cols - 1 {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let cloudNodeName = "cloud" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                func removeCloud() { removeNode(withName: cloudNodeName) }
                func addMarker() { addDotMarker(point: point, nodeName: markerNodeName) }
                func removeMarker() { removeNode(withName: markerNodeName) }
                func removeForbidden() { removeNode(withName: forbiddenNodeName) }
                let (o1, o2) = (stateFrom[r, c], stateTo[r, c])
                guard o1 != o2 else {continue}
                switch o1 {
                case .cloud:
                    removeCloud()
                case .forbidden:
                    removeForbidden()
                case .marker:
                    removeMarker()
                default:
                    break
                }
                switch o2 {
                case .cloud:
                    addCloud(color: .white, point: point, nodeName: cloudNodeName)
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                case .marker:
                    addMarker()
                default:
                    break
                }
            }
        }
    }
}
