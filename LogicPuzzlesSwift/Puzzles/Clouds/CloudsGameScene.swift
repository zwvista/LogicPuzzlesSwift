//
//  CloudsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class CloudsGameScene: SKScene {
    private(set) var gridNode: CloudsGridNode!
    
    func coloredRectSize() -> CGSize {
        let sz = gridNode.blockSize - 4
        return CGSize(width: sz, height: sz)
    }
    
    func addGrid(to view: SKView, rows: Int, cols: Int, blockSize: CGFloat) {
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        gridNode = CloudsGridNode(blockSize: blockSize, rows: rows, cols: cols)
        gridNode.position = CGPoint(x: view.frame.midX - gridNode.blockSize * CGFloat(gridNode.cols + 1) / 2 - offset, y: view.frame.midY + gridNode.blockSize * CGFloat(gridNode.rows + 1) / 2 + offset)
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
    }
    
    func addClouds(from state: CloudsGameState) {
        for p in state.game.pos2cloud {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let cloudNodeName = "cloud" + nodeNameSuffix
            addCloud(color: SKColor.gray, point: point, nodeName: cloudNodeName)
        }
    }
    
    func addCloud(color: SKColor, point: CGPoint, nodeName: String) {
        let cloudNode = SKSpriteNode(color: color, size: coloredRectSize())
        cloudNode.position = point
        cloudNode.name = nodeName
        gridNode.addChild(cloudNode)
    }
    
    func addHints(from state: CloudsGameState) {
        for r in 0 ..< state.rows {
            let p = Position(r, state.cols)
            let n = state.game.row2hint[r]
            addHint(p: p, n: n, s: state.row2state[r])
        }
        for c in 0 ..< state.cols {
            let p = Position(state.rows, c)
            let n = state.game.col2hint[c]
            addHint(p: p, n: n, s: state.col2state[c])
        }
    }
    
    func addHint(p: Position, n: Int, s: CloudsHintState) {
        let point = gridNode.gridPosition(p: p)
        guard n >= 0 else {return}
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addHintNumber(n: n, s: s, point: point, nodeName: hintNodeName)
    }
    
    func addHintNumber(n: Int, s: CloudsHintState, point: CGPoint, nodeName: String) {
        let numberNode = SKLabelNode(text: String(n))
        numberNode.fontColor = s == .normal ? SKColor.white : s == .complete ? SKColor.green : SKColor.red
        numberNode.fontName = numberNode.fontName! + "-Bold"
        // http://stackoverflow.com/questions/32144666/resize-a-sklabelnode-font-size-to-fit
        let scalingFactor = min(gridNode.blockSize / numberNode.frame.width, gridNode.blockSize / numberNode.frame.height)
        numberNode.fontSize *= scalingFactor
        numberNode.verticalAlignmentMode = .center
        numberNode.position = point
        numberNode.name = nodeName
        gridNode.addChild(numberNode)
    }
    
    func levelUpdated(from stateFrom: CloudsGameState, to stateTo: CloudsGameState) {
        func removeNode(withName: String) {
            gridNode.enumerateChildNodes(withName: withName) { (node, pointer) in
                node.removeFromParent()
            }
        }
        func removeHint(p: Position) {
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            removeNode(withName: hintNodeName)
        }
        for r in 0 ..< stateFrom.rows {
            let p = Position(r, stateFrom.cols)
            let n = stateFrom.game.row2hint[r]
            if stateFrom.row2state[r] != stateTo.row2state[r] {
                removeHint(p: p)
                addHint(p: p, n: n, s: stateTo.row2state[r])
            }
        }
        for c in 0 ..< stateFrom.cols {
            let p = Position(stateFrom.rows, c)
            let n = stateFrom.game.col2hint[c]
            if stateFrom.col2state[c] != stateTo.col2state[c] {
                removeHint(p: p)
                addHint(p: p, n: n, s: stateTo.col2state[c])
            }
        }
        for row in 0 ..< stateFrom.rows {
            for col in 0 ..< stateFrom.cols {
                let p = Position(row, col)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(row)-\(col)"
                let cloudNodeName = "cloud" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                func removeCloud() { removeNode(withName: cloudNodeName) }
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
                let (o1, o2) = (stateFrom[row, col], stateTo[row, col])
                guard o1 != o2 else {continue}
                switch o1 {
                case .cloud:
                    removeCloud()
                case .marker:
                    removeMarker()
                default:
                    break
                }
                switch o2 {
                case .cloud:
                    addCloud(color: SKColor.white, point: point, nodeName: cloudNodeName)
                case .marker:
                    addMarker()
                default:
                    break
                }                
            }
        }
    }
}
