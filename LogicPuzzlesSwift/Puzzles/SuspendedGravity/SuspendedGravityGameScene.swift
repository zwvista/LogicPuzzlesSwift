//
//  SuspendedGravityGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class SuspendedGravityGameScene: GameScene<SuspendedGravityGameState> {
    var gridNode: SuspendedGravityGridNode {
        get { getGridNode() as! SuspendedGravityGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: SuspendedGravityGameState, skView: SKView) {
        let game = game as! SuspendedGravityGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: SuspendedGravityGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path: pathToDraw)
        for r in 0..<game.rows + 1 {
            for c in 0..<game.cols + 1 {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                for dir in 1...2 {
                    guard game.dots[r, c][dir] == .line else {continue}
                    switch dir {
                    case 1:
                        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        pathToDraw.addLine(to: CGPoint(x: point.x + gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        lineNode.glowWidth = 8
                    case 2:
                        pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
                        pathToDraw.addLine(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y - gridNode.blockSize / 2))
                        lineNode.glowWidth = 8
                    default:
                        break
                    }
                }
            }
        }
        lineNode.path = pathToDraw
        lineNode.name = "line"
        gridNode.addChild(lineNode)
        
        // add Hints
        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: state.pos2state[p]!, point: point, nodeName: hintNodeName)
        }

        for r in 0..<state.rows {
            for c in 0..<state.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                guard case .forbidden = state[p] else {continue}
                let nodeNameSuffix = "-\(r)-\(c)"
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: SuspendedGravityGameState, to stateTo: SuspendedGravityGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let blockNodeName = "block" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p]!, stateTo.pos2state[p]!)
                if String(describing: o1) != String(describing: o2) {
                    switch o1 {
                    case .forbidden:
                        removeNode(withName: forbiddenNodeName)
                    case .marker:
                        removeNode(withName: markerNodeName)
                    case .block:
                        removeNode(withName: blockNodeName)
                    default:
                        break
                    }
                    switch o2 {
                    case .forbidden:
                        addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                    case .marker:
                        addDotMarker(point: point, nodeName: markerNodeName)
                    case let .block(s):
                        addImage(imageNamed: "tower_wall_noborder", color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: blockNodeName)
                    default:
                        break
                    }
                }
                guard let n = stateFrom.game.pos2hint[p] else {continue}
                guard s1 != s2 || o2.toString() == "block" else {continue}
                removeNode(withName: hintNodeName)
                addHint(n: n, s: s2, point: point, nodeName: hintNodeName)
            }
        }
    }
}
