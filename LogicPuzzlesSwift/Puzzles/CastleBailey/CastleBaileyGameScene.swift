//
//  CastleBaileyGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class CastleBaileyGameScene: GameScene<CastleBaileyGameState> {
    var gridNode: CastleBaileyGridNode {
        get { getGridNode() as! CastleBaileyGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        let markerNode = SKShapeNode(circleOfRadius: gridNode.blockSize / 4)
        markerNode.position = point
        markerNode.name = nodeName
        markerNode.strokeColor = .yellow
        markerNode.fillColor = .black
        markerNode.glowWidth = 1.0
        gridNode.addChild(markerNode)
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName, size: CGSize(width: gridNode.blockSize / 2, height: gridNode.blockSize / 2))
    }

    override func levelInitialized(_ game: AnyObject, state: CastleBaileyGameState, skView: SKView) {
        let game = game as! CastleBaileyGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: CastleBaileyGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
                
        for (p, n) in game.pos2hint {
            let point = gridNode.cornerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: state.pos2state[p]!, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: CastleBaileyGameState, to stateTo: CastleBaileyGameState) {
        let game = stateFrom.game
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let wallNodeName = "wall" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                guard o1 != o2 else {continue}
                switch o1 {
                case .wall:
                    removeNode(withName: wallNodeName)
                case .forbidden:
                    removeNode(withName: forbiddenNodeName)
                case .marker:
                    removeNode(withName: markerNodeName)
                default:
                    break
                }
                switch o2 {
                case .wall:
                    addBlock(color: .lightGray, point: point, nodeName: wallNodeName)
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                case .marker:
                    addDotMarker(point: point, nodeName: markerNodeName)
                default:
                    break
                }
            }
        }
        for (p, n) in game.pos2hint {
            let (s1, s2) = (stateFrom.pos2state[p]!, stateTo.pos2state[p]!)
            guard s1 != s2 || (CastleBaileyGame.offset2.contains {
                let p2 = p + $0
                return game.isValid(p: p2) && stateFrom[p2] == .empty && stateTo[p2] == .wall
            }) else {continue}
            let point = gridNode.cornerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            removeNode(withName: hintNodeName)
            addHint(n: n, s: s2, point: point, nodeName: hintNodeName)
        }
    }
}
