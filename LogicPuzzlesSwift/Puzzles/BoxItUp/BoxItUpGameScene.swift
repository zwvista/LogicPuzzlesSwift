//
//  BoxItUpGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class BoxItUpGameScene: GameScene<BoxItUpGameState> {
    var gridNode: BoxItUpGridNode {
        get {return getGridNode() as! BoxItUpGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addHintNumber(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    func addLine(dir: Int, color: SKColor, point: CGPoint, nodeName: String) {
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path:pathToDraw)
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
        lineNode.path = pathToDraw
        lineNode.strokeColor = color
        lineNode.name = nodeName
        gridNode.addChild(lineNode)
    }
    
    override func levelInitialized(_ game: AnyObject, state: BoxItUpGameState, skView: SKView) {
        let game = game as! BoxItUpGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: BoxItUpGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset))
        
        // addHints
        for (p, n) in game.pos2hint {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNumberNodeName = "hintNumber" + nodeNameSuffix
            addHintNumber(n: n, s: state.pos2state[p]!, point: point, nodeName: hintNumberNodeName)
        }
        
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                for dir in 1...2 {
                    guard game[r, c][dir] else {continue}
                    let nodeNameSuffix = "-\(r)-\(c)-\(dir)"
                    let lineNodeName = "line" + nodeNameSuffix
                    addLine(dir: dir, color: .white, point: point, nodeName: lineNodeName)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: BoxItUpGameState, to stateTo: BoxItUpGameState) {
        let markerOffset: CGFloat = 7.5
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                for dir in 1...2 {
                    guard !stateFrom.game[r, c][dir] else {continue}
                    let nodeNameSuffix = "-\(r)-\(c)-\(dir)"
                    let lineNodeName = "line" + nodeNameSuffix
                    func removeLine() { removeNode(withName: lineNodeName) }
                    let (o1, o2) = (stateFrom[p][dir], stateTo[p][dir])
                    guard o1 != o2 else {continue}
                    if o1 {removeLine()}
                    if o2 {addLine(dir: dir, color: .green, point: point, nodeName: lineNodeName)}
                }
                let nodeNameSuffix = "-\(r)-\(c)"
                let hintNumberNodeName = "hintNumber" + nodeNameSuffix
                func removeHintNumber() { removeNode(withName: hintNumberNodeName) }
                guard let s1 = stateFrom.pos2state[p], let s2 = stateTo.pos2state[p] else {continue}
                if s1 != s2 {
                    removeHintNumber()
                    addHintNumber(n: stateFrom.game.pos2hint[p]!, s: s2, point: point, nodeName: hintNumberNodeName)
                }
            }
        }
    }
}
