//
//  MagnetsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class MagnetsGameScene: GameScene<MagnetsGameState> {
    private(set) var gridNode: MagnetsGridNode!
    
    func coloredRectSize() -> CGSize {
        let sz = gridNode.blockSize - 4
        return CGSize(width: sz, height: sz)
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
    
    override func levelInitialized(_ game: AnyObject, state: MagnetsGameState, skView: SKView) {
        let game = game as! MagnetsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols + 2)
        
        // add Grid
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        gridNode = MagnetsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols)
        gridNode.position = CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols + 2) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows + 2) / 2 + offset)
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
        
        for a in game.areas {
            let point = gridNode.gridPosition(p: a.p)
            switch a.type {
            case .single:
                let rectNode = SKShapeNode(rectOf: CGSize(width: blockSize, height: blockSize))
                rectNode.strokeColor = .white
                rectNode.position = point
                gridNode.addChild(rectNode)
            case .horizontal:
                let rectNode = SKShapeNode(rectOf: CGSize(width: blockSize * 2, height: blockSize))
                rectNode.strokeColor = .white
                rectNode.position = CGPoint(x: point.x + CGFloat(blockSize) / 2, y: point.y)
                gridNode.addChild(rectNode)
            case .vertical:
                let rectNode = SKShapeNode(rectOf: CGSize(width: blockSize, height: blockSize * 2))
                rectNode.strokeColor = .white
                rectNode.position = point
                rectNode.position = CGPoint(x: point.x, y: point.y - CGFloat(blockSize) / 2)
                gridNode.addChild(rectNode)
            }
        }
        
        // add Hints
        for r in 0..<game.rows {
            for c in 0..<2 {
                let p = Position(r, game.cols + c)
                let n = state.game.row2hint[r * 2 + c]
                addHint(p: p, n: n, s: state.row2state[r * 2 + c])
            }
        }
        for c in 0..<game.cols {
            for r in 0..<2 {
                let p = Position(game.rows + r, c)
                let n = state.game.col2hint[c * 2 + r]
                addHint(p: p, n: n, s: state.col2state[c * 2 + r])
            }
        }
    }
    
    override func levelUpdated(from stateFrom: MagnetsGameState, to stateTo: MagnetsGameState) {
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
            let n = stateFrom.game.row2hint[r]
            if stateFrom.row2state[r] != stateTo.row2state[r] {
                removeHint(p: p)
                addHint(p: p, n: n, s: stateTo.row2state[r])
            }
        }
        for c in 0..<stateFrom.cols {
            let p = Position(stateFrom.rows, c)
            let n = stateFrom.game.col2hint[c]
            if stateFrom.col2state[c] != stateTo.col2state[c] {
                removeHint(p: p)
                addHint(p: p, n: n, s: stateTo.col2state[c])
            }
        }
        for row in 0..<stateFrom.rows {
            for col in 0..<stateFrom.cols {
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
                case .positive:
                    removeCloud()
                case .negative:
                    removeCloud()
                case .marker:
                    removeMarker()
                default:
                    break
                }
                switch o2 {
                case .positive:
                    addCloud(color: SKColor.white, point: point, nodeName: cloudNodeName)
                case .negative:
                    removeCloud()
                case .marker:
                    addMarker()
                default:
                    break
                }                
            }
        }
    }
}
