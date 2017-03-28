//
//  LineSweeperGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class LineSweeperGameScene: GameScene<LineSweeperGameState> {
    var gridNode: LineSweeperGridNode {
        get {return getGridNode() as! LineSweeperGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: LineSweeperGameState, skView: SKView) {
        let game = game as! LineSweeperGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: LineSweeperGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addHints
        for (p, n) in game.pos2hint {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: state.pos2state[p]!, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: LineSweeperGameState, to stateTo: LineSweeperGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                for dir in 1...2 {
                    let p = Position(r, c)
                    let point = gridNode.gridPosition(p: p)
                    let nodeNameSuffix = "-\(r)-\(c)-\(dir)"
                    let hintNodeName = "hint" + nodeNameSuffix
                    let lineNodeName = "line" + nodeNameSuffix
                    func removeHint() { removeNode(withName: hintNodeName) }
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
                        lineNode.strokeColor = .yellow
                        lineNode.name = lineNodeName
                        gridNode.addChild(lineNode)
                    }
                    let (o1, o2) = (stateFrom[p][dir], stateTo[p][dir])
                    if o1 != o2 {
                        if o1 {removeLine()}
                        if o2 {addLine()}
                    }
                    guard let s1 = stateFrom.pos2state[p], let s2 = stateTo.pos2state[p] else {continue}
                    if s1 != s2 {
                        removeHint()
                        addHint(n: stateFrom.game.pos2hint[p]!, s: s2, point: point, nodeName: hintNodeName)
                    }
                }
            }
        }
    }
}
