//
//  MagnetsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class MagnetsGameScene: GameScene<MagnetsGameState> {
    var gridNode: MagnetsGridNode {
        get { getGridNode() as! MagnetsGridNode }
        set { setGridNode(gridNode: newValue) }
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
    
    func addPole(o: MagnetsObject, colorBlendFactor: CGFloat, point: CGPoint, nodeName: String) {
        addImage(imageNamed: o == .positive ? "128_navigate_plus_red" : "128_navigate_minus", color: .black, colorBlendFactor: colorBlendFactor, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: MagnetsGameState, skView: SKView) {
        let game = game as! MagnetsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols + 2)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: MagnetsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols + 2) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows + 2) / 2 + offset))
        
        for a in game.areas {
            let point = gridNode.gridPosition(p: a.p)
            switch a.type {
            case .single:
                let rectNode = SKShapeNode(rectOf: CGSize(width: blockSize, height: blockSize))
                rectNode.position = point
                gridNode.addChild(rectNode)
                let pathToDraw = CGMutablePath()
                let lineNode = SKShapeNode(path:pathToDraw)
                pathToDraw.move(to: CGPoint(x: point.x + CGFloat(blockSize) / 2, y: point.y + CGFloat(blockSize) / 2))
                pathToDraw.addLine(to: CGPoint(x: point.x - CGFloat(blockSize) / 2, y: point.y - CGFloat(blockSize) / 2))
                lineNode.path = pathToDraw
                gridNode.addChild(lineNode)
            case .horizontal:
                let rectNode = SKShapeNode(rectOf: CGSize(width: blockSize * 2, height: blockSize))
                rectNode.position = CGPoint(x: point.x + CGFloat(blockSize) / 2, y: point.y)
                gridNode.addChild(rectNode)
            case .vertical:
                let rectNode = SKShapeNode(rectOf: CGSize(width: blockSize, height: blockSize * 2))
                rectNode.position = point
                rectNode.position = CGPoint(x: point.x, y: point.y - CGFloat(blockSize) / 2)
                gridNode.addChild(rectNode)
            }
        }
        
        // add Hints
        for r in 0..<game.rows {
            for c in 0..<2 {
                let p = Position(r, game.cols + c)
                let n = game.row2hint[r * 2 + c]
                addHint(p: p, n: n, s: state.row2state[r * 2 + c])
            }
        }
        for c in 0..<game.cols {
            for r in 0..<2 {
                let p = Position(game.rows + r, c)
                let n = game.col2hint[c * 2 + r]
                addHint(p: p, n: n, s: state.col2state[c * 2 + r])
            }
        }
        
        let poleNodeName = "pole"
        var point = gridNode.gridPosition(p: Position(game.rows, game.cols))
        addPole(o: .positive, colorBlendFactor: 0.5, point: point, nodeName: poleNodeName)
        point = gridNode.gridPosition(p: Position(game.rows + 1, game.cols + 1))
        addPole(o: .negative, colorBlendFactor: 0.5, point: point, nodeName: poleNodeName)
    }
    
    override func levelUpdated(from stateFrom: MagnetsGameState, to stateTo: MagnetsGameState) {
        func removeHint(p: Position) {
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            removeNode(withName: hintNodeName)
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<2 {
                let p = Position(r, stateFrom.cols + c)
                let id = r * 2 + c
                let n = stateFrom.game.row2hint[id]
                if stateFrom.row2state[id] != stateTo.row2state[id] {
                    removeHint(p: p)
                    addHint(p: p, n: n, s: stateTo.row2state[id])
                }
            }
        }
        for c in 0..<stateFrom.cols {
            for r in 0..<2 {
                let p = Position(stateFrom.rows + r, c)
                let id = c * 2 + r
                let n = stateFrom.game.col2hint[id]
                if stateFrom.col2state[id] != stateTo.col2state[id] {
                    removeHint(p: p)
                    addHint(p: p, n: n, s: stateTo.col2state[id])
                }
            }
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let poleNodeName = "pole" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                func removePole() { removeNode(withName: poleNodeName) }
                func addMarker() { addDotMarker(point: point, nodeName: markerNodeName) }
                func removeMarker() { removeNode(withName: markerNodeName) }
                let (o1, o2) = (stateFrom[r, c], stateTo[r, c])
                guard o1 != o2 else {continue}
                switch o1 {
                case .positive, .negative:
                    removePole()
                case .marker:
                    removeMarker()
                default:
                    break
                }
                switch o2 {
                case .positive, .negative:
                    addPole(o: o2, colorBlendFactor: 0.0, point: point, nodeName: poleNodeName)
                case .marker:
                    addMarker()
                default:
                    break
                }                
            }
        }
    }
}
