//
//  TrafficWardenRevengeGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class TrafficWardenRevengeGameScene: GameScene<TrafficWardenRevengeGameState> {
    var gridNode: TrafficWardenRevengeGridNode {
        get { getGridNode() as! TrafficWardenRevengeGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: n == TrafficWardenRevengeGame.PUZ_UNKNOWN ? "?" : n == TrafficWardenRevengeGame.PUZ_UNKNOWN_10 ? "1?" : String(n), fontColor: s == .normal ? .black : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: TrafficWardenRevengeGameState, skView: SKView) {
        let game = game as! TrafficWardenRevengeGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: TrafficWardenRevengeGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for (p, hint) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            let ch = hint.light
            addImage(imageNamed: "nav_plain_" + (ch == TrafficWardenRevengeGame.PUZ_GREEN ? "green" : "red") , color: .red, colorBlendFactor: 0.0, point: point, nodeName: "trafficwarden")
            addHint(n: hint.len, s: .normal, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: TrafficWardenRevengeGameState, to stateTo: TrafficWardenRevengeGameState) {
        for (p, hint) in stateFrom.game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            let (s1, s2) = (stateFrom.pos2state[p]!, stateTo.pos2state[p]!)
            if s1 != s2 {
                removeNode(withName: hintNodeName)
                addHint(n: hint.len, s: s2, point: point, nodeName: hintNodeName)
            }
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                for dir in 1...2 {
                    let nodeNameSuffix = "-\(r)-\(c)-\(dir)"
                    let lineNodeName = "line" + nodeNameSuffix
                    func removeLine() { removeNode(withName: lineNodeName) }
                    func addLine() {
                        let pathToDraw = CGMutablePath()
                        let lineNode = SKShapeNode(path:pathToDraw)
                        lineNode.glowWidth = 8
                        switch dir {
                        case 1:
                            pathToDraw.move(to: CGPoint(x: point.x, y: point.y))
                            pathToDraw.addLine(to: CGPoint(x: point.x + gridNode.blockSize, y: point.y))
                        case 2:
                            pathToDraw.move(to: CGPoint(x: point.x, y: point.y))
                            pathToDraw.addLine(to: CGPoint(x: point.x, y: point.y - gridNode.blockSize))
                        default:
                            break
                        }
                        lineNode.path = pathToDraw
                        lineNode.strokeColor = .green
                        lineNode.name = lineNodeName
                        gridNode.addChild(lineNode)
                    }
                    let (o1, o2) = (stateFrom[p][dir], stateTo[p][dir])
                    guard o1 != o2 else {continue}
                    if o1 { removeLine() }
                    if o2 { addLine() }
                }
            }
        }
    }
}
