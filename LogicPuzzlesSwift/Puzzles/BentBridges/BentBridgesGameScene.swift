//
//  BentBridgesGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class BentBridgesGameScene: GameScene<BentBridgesGameState> {
    var gridNode: BentBridgesGridNode {
        get { getGridNode() as! BentBridgesGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: BentBridgesGameState, skView: SKView) {
        let game = game as! BentBridgesGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset: CGFloat = 0.5
        addGrid(gridNode: BentBridgesGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add islands
        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let islandNode = SKShapeNode(circleOfRadius: blockSize / 2)
            islandNode.position = point
            islandNode.name = "island"
            islandNode.strokeColor = .white
            islandNode.glowWidth = 1.0
            gridNode.addChild(islandNode)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: .normal, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: BentBridgesGameState, to stateTo: BentBridgesGameState) {
        let game = stateFrom.game
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
                let nodeNameSuffix = "-\(r)-\(c)"
                let hintNodeName = "hint" + nodeNameSuffix
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                guard s1 != s2 else {continue}
                removeNode(withName: hintNodeName)
                addHint(n: game.pos2hint[p]!, s: s2!, point: point, nodeName: hintNodeName)
            }
        }
    }
}
