//
//  ProofOfQuiltGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class ProofOfQuiltGameScene: GameScene<ProofOfQuiltGameState> {
    var gridNode: ProofOfQuiltGridNode {
        get { getGridNode() as! ProofOfQuiltGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    var blockSize: CGFloat = 0

    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .gray : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: ProofOfQuiltGameState, skView: SKView) {
        let game = game as! ProofOfQuiltGame
        removeAllChildren()
        blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: ProofOfQuiltGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
                
        // add Hints
        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addBlock(color: .white, point: point, nodeName: "block")
            addHint(n: n, s: state.pos2state[p]!, point: point, nodeName: hintNodeName)
        }
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                guard state[p] == .forbidden else {continue}
                addForbiddenMarker(point: point, nodeName: tileNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: ProofOfQuiltGameState, to stateTo: ProofOfQuiltGameState) {
        let game = stateFrom.game
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                guard o1 != o2 else {continue}
                if o1 != .empty { removeNode(withName: tileNodeName) }
                let v1 = CGPoint(x: point.x - blockSize / 2, y: point.y + blockSize / 2)
                let v2 = CGPoint(x: point.x + blockSize / 2, y: point.y + blockSize / 2)
                let v3 = CGPoint(x: point.x - blockSize / 2, y: point.y - blockSize / 2)
                let v4 = CGPoint(x: point.x + blockSize / 2, y: point.y - blockSize / 2)
                func addTriangle(v1: CGPoint, v2: CGPoint, v3: CGPoint) {
                    let path = CGMutablePath()
                    path.move(to: v1)
                    path.addLine(to: v2)
                    path.addLine(to: v3)
                    path.addLine(to: v1)
                    path.closeSubpath()
                    let triangle = SKShapeNode(path: path)
                    triangle.name = tileNodeName
                    triangle.fillColor = .white
                    gridNode.addChild(triangle)
                }
                switch o2 {
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: tileNodeName)
                case .marker:
                    addDotMarker(point: point, nodeName: tileNodeName)
                case ProofOfQuiltObject.triangleA:
                    addTriangle(v1: v1, v2: v2, v3: v3)
                case ProofOfQuiltObject.triangleB:
                    addTriangle(v1: v1, v2: v2, v3: v4)
                case ProofOfQuiltObject.triangleC:
                    addTriangle(v1: v1, v2: v3, v3: v4)
                case ProofOfQuiltObject.triangleD:
                    addTriangle(v1: v2, v2: v3, v3: v4)
                default:
                    break
                }
            }
        }
        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            let (s1, s2) = (stateFrom.pos2state[p]!, stateTo.pos2state[p]!)
            guard s1 != s2 else {continue}
            removeNode(withName: hintNodeName)
            addHint(n: n, s: s2, point: point, nodeName: hintNodeName)
        }
    }
}
