//
//  LoopAndBlocksGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class LoopAndBlocksGameScene: GameScene<LoopAndBlocksGameState> {
    var gridNode: LoopAndBlocksGridNode {
        get { getGridNode() as! LoopAndBlocksGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: LoopAndBlocksGameState, skView: SKView) {
        let game = game as! LoopAndBlocksGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: LoopAndBlocksGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: state.pos2stateHint[p]!, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: LoopAndBlocksGameState, to stateTo: LoopAndBlocksGameState) {
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
                let squareNodeName = "square" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let (b1, b2) = (stateFrom.squares.contains(p), stateTo.squares.contains(p))
                let (s1, s2) = (stateFrom.pos2stateAllowed[p], stateTo.pos2stateAllowed[p])
                if b1 != b2 || s1 != s2 {
                    if b1 { removeNode(withName: squareNodeName) }
                    if b2 { addBlock(color: s2 == .error ? .red : .white, point: point, nodeName: squareNodeName) }
                }
                let (s3, s4) = (stateFrom.pos2stateHint[p], stateTo.pos2stateHint[p])
                if s3 != s4 {
                    removeNode(withName: hintNodeName)
                    addHint(n: stateFrom.game.pos2hint[p]!, s: s4!, point: point, nodeName: hintNodeName)
                }
            }
        }
    }
}
