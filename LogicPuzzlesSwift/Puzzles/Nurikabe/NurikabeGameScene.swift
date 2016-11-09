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
        let numberNode = SKLabelNode(text: String(n))
        numberNode.fontColor = s == .normal ? SKColor.black : s == .complete ? SKColor.green : SKColor.red
        numberNode.fontName = numberNode.fontName! + "-Bold"
        // http://stackoverflow.com/questions/32144666/resize-a-sklabelnode-font-size-to-fit
        let scalingFactor = min(gridNode.blockSize / numberNode.frame.width, gridNode.blockSize / numberNode.frame.height)
        numberNode.fontSize *= scalingFactor
        numberNode.verticalAlignmentMode = .center
        numberNode.position = point
        numberNode.name = nodeName
        gridNode.addChild(numberNode)
    }
    
    override func levelInitialized(_ game: AnyObject, state: NurikabeGameState, skView: SKView) {
        let game = game as! NurikabeGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        gridNode = NurikabeGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols)
        gridNode.position = CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset)
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
        
        // addWalls
        for row in 0..<game.rows {
            for col in 0..<game.cols {
                let p = Position(row, col)
                guard case let .hint(s) = state[p] else {continue}
                let n = state.game.pos2hint[p]!
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(row)-\(col)"
                let hintNodeName = "hint" + nodeNameSuffix
                addHint(n: n, s: s, point: point, nodeName: hintNodeName)
            }
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
                    let wallNode = SKSpriteNode(color: SKColor.white, size: coloredRectSize())
                    wallNode.position = point
                    wallNode.name = wallNodeName
                    gridNode.addChild(wallNode)
                }
                func removeWall() { removeNode(withName: wallNodeName) }
                func addMarker() {
                    let markerNode = SKShapeNode(circleOfRadius: 5)
                    markerNode.position = point
                    markerNode.name = markerNodeName
                    markerNode.strokeColor = SKColor.white
                    markerNode.glowWidth = 1.0
                    markerNode.fillColor = SKColor.white
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
