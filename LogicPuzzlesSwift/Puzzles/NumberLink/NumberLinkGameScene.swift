//
//  NumberLinkGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class NumberLinkGameScene: GameScene<NumberLinkGameState> {
    var gridNode: NumberLinkGridNode {
        get { getGridNode() as! NumberLinkGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: String, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: n, fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName, sampleText: "10")
    }

    override func levelInitialized(_ game: AnyObject, state: NumberLinkGameState, skView: SKView) {
        let game = game as! NumberLinkGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: NumberLinkGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addNumbers
        for (p, n) in game.pos2hint {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: String(n), s: .normal, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: NumberLinkGameState, to stateTo: NumberLinkGameState) {
        for (p, n) in stateFrom.game.pos2hint {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            let (s1, s2) = (stateFrom.pos2state[p]!, stateTo.pos2state[p]!)
            if s1 != s2 {
                removeNode(withName: hintNodeName)
                addHint(n: String(n), s: s2, point: point, nodeName: hintNodeName)
            }
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                for dir in 1...2 {
                    let p = Position(r, c)
                    let point = gridNode.gridPosition(p: p)
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
                        lineNode.strokeColor = .yellow
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
