//
//  CloudsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class CloudsGameScene: GameScene<CloudsGameState> {
    var gridNode: CloudsGridNode {
        get {return getGridNode() as! CloudsGridNode}
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
    
    override func levelInitialized(_ game: AnyObject, state: CloudsGameState, skView: SKView) {
        let game = game as! CloudsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols + 1)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: CloudsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols + 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows + 1) / 2 + offset))
        
        // add Hints
        for r in 0..<game.rows {
            let p = Position(r, game.cols)
            let n = state.game.row2hint[r]
            addHint(p: p, n: n, s: state.row2state[r])
        }
        for c in 0..<game.cols {
            let p = Position(game.rows, c)
            let n = state.game.col2hint[c]
            addHint(p: p, n: n, s: state.col2state[c])
        }
        
        // add Clouds
        for p in game.pos2cloud {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let cloudNodeName = "cloud" + nodeNameSuffix
            addCloud(color: .gray, point: point, nodeName: cloudNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: CloudsGameState, to stateTo: CloudsGameState) {
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
                    markerNode.strokeColor = .white
                    markerNode.glowWidth = 1.0
                    markerNode.fillColor = .white
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
                    addCloud(color: .white, point: point, nodeName: cloudNodeName)
                case .marker:
                    addMarker()
                default:
                    break
                }                
            }
        }
    }
}
