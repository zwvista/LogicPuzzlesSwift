//
//  HitoriGameScene.swift
//  LogicGamesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class HitoriGameScene: SKScene {
    private(set) var gridNode: HitoriGridNode!
    
    func coloredRectSize() -> CGSize {
        let sz = gridNode.blockSize - 4
        return CGSize(width: sz, height: sz)
    }
    
    func addGrid(to view: SKView, rows: Int, cols: Int, blockSize: CGFloat) {
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        gridNode = HitoriGridNode(blockSize: blockSize, rows: rows, cols: cols)
        gridNode.position = CGPoint(x: view.frame.midX - gridNode.blockSize * CGFloat(gridNode.cols) / 2 - offset, y: view.frame.midY + gridNode.blockSize * CGFloat(gridNode.rows) / 2 + offset)
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
    }
    
    func addNumbers(from state: HitoriGameState) {
        for r in 0 ..< state.rows {
            for c in 0 ..< state.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let n = state.game[p]
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let numberNodeName = "number" + nodeNameSuffix
                addNumber(n: n, point: point, nodeName: numberNodeName)
            }
        }
    }
    
    func addNumber(n: Character, point: CGPoint, nodeName: String) {
        let numberNode = SKLabelNode(text: String(n))
        numberNode.fontColor = SKColor.white
        numberNode.fontName = numberNode.fontName! + "-Bold"
        // http://stackoverflow.com/questions/32144666/resize-a-sklabelnode-font-size-to-fit
        let scalingFactor = min(gridNode.blockSize / numberNode.frame.width, gridNode.blockSize / numberNode.frame.height)
        numberNode.fontSize *= scalingFactor
        numberNode.verticalAlignmentMode = .center
        numberNode.position = point
        numberNode.name = nodeName
        gridNode.addChild(numberNode)
    }
    
    func process(from stateFrom: HitoriGameState, to stateTo: HitoriGameState) {
        for row in 0 ..< stateFrom.rows {
            for col in 0 ..< stateFrom.cols {
                let p = Position(row, col)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(row)-\(col)"
                let numberNodeName = "number" + nodeNameSuffix
                let darkenNodeName = "darken" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                func removeNode(withName: String) {
                    gridNode.enumerateChildNodes(withName: withName) { (node, pointer) in
                        node.removeFromParent()
                    }
                }
                func addNumber2() { addNumber(n: stateFrom.game[p], point: point, nodeName: numberNodeName) }
                func removeNumber() { removeNode(withName: numberNodeName) }
                func addDarken() {
                    let darkenNode = SKSpriteNode(color: SKColor.lightGray, size: coloredRectSize())
                    darkenNode.position = point
                    darkenNode.name = darkenNodeName
                    gridNode.addChild(darkenNode)
                }
                func removeDarken() { removeNode(withName: darkenNodeName) }
                func addMarker() {
                    let markerNode = SKShapeNode(circleOfRadius: gridNode.blockSize / 2)
                    markerNode.position = point
                    markerNode.name = markerNodeName
                    markerNode.strokeColor = SKColor.white
                    markerNode.glowWidth = 1.0
                    gridNode.addChild(markerNode)
                }
                func removeMarker() { removeNode(withName: markerNodeName) }
                let (o1, o2) = (stateFrom[row, col], stateTo[row, col])
                guard o1 != o2 else {continue}
                switch o1 {
                case .darken:
                    removeDarken()
                case .marker:
                    removeMarker()
                default:
                    break
                }
                switch o2 {
                case .darken:
                    removeNumber()
                    addDarken()
                    addNumber2()
                case .marker:
                    addMarker()
                default:
                    break
                }                
            }
        }
    }
}
