//
//  HitoriGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class HitoriGameScene: GameScene<HitoriGameState> {
    private(set) var gridNode: HitoriGridNode!
    
    func coloredRectSize() -> CGSize {
        let sz = gridNode.blockSize - 4
        return CGSize(width: sz, height: sz)
    }
    
    func addNumber(n: String, s: HintState, point: CGPoint, nodeName: String) {
        let numberNode = SKLabelNode(text: n)
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
    
    func addHint(p: Position, n: String) {
        let point = gridNode.gridPosition(p: p)
        guard !n.isEmpty else {return}
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addNumber(n: n, s: .error, point: point, nodeName: hintNodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: HitoriGameState, skView: SKView) {
        let game = game as! HitoriGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols + 1)
        
        // addGrid
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        gridNode = HitoriGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols)
        gridNode.position = CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols + 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows + 1) / 2 + offset)
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
        
        // addNumbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let n = state.game[p]
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let numberNodeName = "number" + nodeNameSuffix
                addNumber(n: String(n), s: .normal, point: point, nodeName: numberNodeName)
            }
        }
        
        // addHints
        for r in 0..<game.rows {
            let p = Position(r, game.cols)
            let n = state.row2hint[r]
            addHint(p: p, n: n)
        }
        for c in 0..<game.cols {
            let p = Position(game.rows, c)
            let n = state.col2hint[c]
            addHint(p: p, n: n)
        }
    }
    
    override func levelUpdated(from stateFrom: HitoriGameState, to stateTo: HitoriGameState) {
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
        for r in 0..<stateFrom.rows {
            let p = Position(r, stateFrom.cols)
            let n = stateTo.row2hint[r]
            if stateFrom.row2hint[r] != n {
                removeHint(p: p)
                addHint(p: p, n: n)
            }
        }
        for c in 0..<stateFrom.cols {
            let p = Position(stateFrom.rows, c)
            let n = stateTo.col2hint[c]
            if stateFrom.col2hint[c] != n {
                removeHint(p: p)
                addHint(p: p, n: n)
            }
        }
        for row in 0..<stateFrom.rows {
            for col in 0..<stateFrom.cols {
                let p = Position(row, col)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(row)-\(col)"
                let numberNodeName = "number" + nodeNameSuffix
                let darkenNodeName = "darken" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                func addNumber2() { addNumber(n: String(stateFrom.game[p]), s: .normal, point: point, nodeName: numberNodeName) }
                func removeNumber() { removeNode(withName: numberNodeName) }
                func addDarken() {
                    let darkenNode = SKSpriteNode(color: .lightGray, size: coloredRectSize())
                    darkenNode.position = point
                    darkenNode.name = darkenNodeName
                    gridNode.addChild(darkenNode)
                }
                func removeDarken() { removeNode(withName: darkenNodeName) }
                func addMarker() {
                    let markerNode = SKShapeNode(circleOfRadius: gridNode.blockSize / 2)
                    markerNode.position = point
                    markerNode.name = markerNodeName
                    markerNode.strokeColor = .white
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
