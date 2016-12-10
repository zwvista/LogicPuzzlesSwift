//
//  MosaikGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class MosaikGameScene: GameScene<MosaikGameState> {
    private(set) var gridNode: MosaikGridNode!
    
    func coloredRectSize() -> CGSize {
        let sz = gridNode.blockSize - 4
        return CGSize(width: sz, height: sz)
    }
    
    func addHintNumber(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        let numberNode = SKLabelNode(text: String(n))
        numberNode.fontColor = s == .normal ? .white : s == .complete ? .green : .red
        numberNode.fontName = numberNode.fontName! + "-Bold"
        // http://stackoverflow.com/questions/32144666/resize-a-sklabelnode-font-size-to-fit
        let scalingFactor = min(gridNode.blockSize / numberNode.frame.width, gridNode.blockSize / numberNode.frame.height)
        numberNode.fontSize *= scalingFactor
        numberNode.verticalAlignmentMode = .center
        numberNode.position = point
        numberNode.name = nodeName
        gridNode.addChild(numberNode)
    }
    
    override func levelInitialized(_ game: AnyObject, state: MosaikGameState, skView: SKView) {
        let game = game as! MosaikGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        gridNode = MosaikGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols)
        gridNode.position = CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset)
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
        
        // addHints
        for (p, n) in game.pos2hint {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNumberNodeName = "hintNumber" + nodeNameSuffix
            addHintNumber(n: n, s: state.pos2state[p]!, point: point, nodeName: hintNumberNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: MosaikGameState, to stateTo: MosaikGameState) {
        let markerOffset: CGFloat = 7.5
        for row in 0..<stateFrom.rows {
            for col in 0..<stateFrom.cols {
                let p = Position(row, col)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(row)-\(col)"
                let filledCellNodeName = "filledCell" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let hintNumberNodeName = "hintNumber" + nodeNameSuffix
                func addHintNumber2() { addHintNumber(n: stateFrom.game.pos2hint[p]!, s: stateTo.pos2state[p]!, point: point, nodeName: hintNumberNodeName) }
                func removeNode(withName: String) {
                    gridNode.enumerateChildNodes(withName: withName) { (node, pointer) in
                        node.removeFromParent()
                    }
                }
                func removeHintNumber() { removeNode(withName: hintNumberNodeName) }
                func addFilledCell() {
                    let filledCellNode = SKSpriteNode(color: .purple, size: coloredRectSize())
                    filledCellNode.position = point
                    filledCellNode.name = filledCellNodeName
                    gridNode.addChild(filledCellNode)
                }
                func removeFilledCell() { removeNode(withName: filledCellNodeName) }
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
                        if b {removeHintNumber()}
                        addFilledCell()
                        if b {addHintNumber2()}
                    case .marker:
                        addMarker()
                    default:
                        break
                    }
                }
                guard let s1 = stateFrom.pos2state[p], let s2 = stateTo.pos2state[p] else {continue}
                if s1 != s2 {
                    removeHintNumber()
                    addHintNumber2()
                }
            }
        }
    }
}
