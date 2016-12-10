//
//  NurikabeGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class NurikabeGameScene: GameScene<NurikabeGameState> {
    private(set) var gridNode: NurikabeGridNode!
    
    func coloredRectSize() -> CGSize {
        let sz = gridNode.blockSize - 4
        return CGSize(width: sz, height: sz)
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(parentNode: gridNode, text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: NurikabeGameState, skView: SKView) {
        let game = game as! NurikabeGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        gridNode = NurikabeGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols)
        gridNode.position = CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset)
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
        
        // add Hints
        for (p, n) in game.pos2hint {
            guard case let .hint(state: s) = state[p] else {continue}
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: s, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: NurikabeGameState, to stateTo: NurikabeGameState) {
        for row in 0..<stateFrom.rows {
            for col in 0..<stateFrom.cols {
                let point = gridNode.gridPosition(p: Position(row, col))
                let nodeNameSuffix = "-\(row)-\(col)"
                let wallNodeName = "wall" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                func removeNode(withName: String) {
                    gridNode.enumerateChildNodes(withName: withName) { (node, pointer) in
                        node.removeFromParent()
                    }
                }
                func removeHint() { removeNode(withName: hintNodeName) }
                func addWall() {
                    let wallNode = SKSpriteNode(color: .white, size: coloredRectSize())
                    wallNode.position = point
                    wallNode.name = wallNodeName
                    gridNode.addChild(wallNode)
                }
                func removeWall() { removeNode(withName: wallNodeName) }
                func addMarker() {
                    let markerNode = SKShapeNode(circleOfRadius: 5)
                    markerNode.position = point
                    markerNode.name = markerNodeName
                    markerNode.strokeColor = .white
                    markerNode.glowWidth = 1.0
                    markerNode.fillColor = .white
                    gridNode.addChild(markerNode)
                }
                func removeMarker() { removeNode(withName: markerNodeName) }
                let (ot1, ot2) = (stateFrom[row, col], stateTo[row, col])
                guard String(describing: ot1) != String(describing: ot2) else {continue}
                switch ot1 {
                case .wall:
                    removeWall()
                case .marker:
                    removeMarker()
                case .hint:
                    removeHint()
                default:
                    break
                }
                switch ot2 {
                case .wall:
                    addWall()
                case .marker:
                    addMarker()
                case let .hint(s):
                    let n = stateTo.game.pos2hint[Position(row, col)]!
                    addHint(n: n, s: s, point: point, nodeName: hintNodeName)
                default:
                    break
                }
            }
        }
    }
}
