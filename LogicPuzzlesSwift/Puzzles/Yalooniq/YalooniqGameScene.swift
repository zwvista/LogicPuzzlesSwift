//
//  YalooniqGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class YalooniqGameScene: GameScene<YalooniqGameState> {
    var gridNode: YalooniqGridNode {
        get { getGridNode() as! YalooniqGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName, size: CGSize(width: gridNode.blockSize, height: gridNode.blockSize / 2))
    }
    
    func getHintPoint(p: Position) -> CGPoint {
        let offset: CGFloat = 0.5
        let x = (CGFloat(p.col) + CGFloat(0.25)) * gridNode.blockSize + offset
        let y = -((CGFloat(p.row) + CGFloat(0.5)) * gridNode.blockSize + offset)
        return CGPoint(x: x, y: y)
    }
    
    func addTriangle(in rect: CGRect, dir: Int) {
        let cx = rect.midX
        let cy = rect.midY
        let w = rect.width
        let h = rect.height
        
        let side = min(w, h)
        let path = CGMutablePath()
        
        var v1, v2, v3: CGPoint
        
        switch dir {
        case 0: // up
            v1 = CGPoint(x: cx, y: cy + side/2)
            v2 = CGPoint(x: cx - w/2, y: cy - side/2)
            v3 = CGPoint(x: cx + w/2, y: cy - side/2)
        case 2: // down
            v1 = CGPoint(x: cx, y: cy - side/2)
            v2 = CGPoint(x: cx - w/2, y: cy + side/2)
            v3 = CGPoint(x: cx + w/2, y: cy + side/2)
        case 3: // left
            v1 = CGPoint(x: cx - w/2, y: cy)
            v2 = CGPoint(x: cx + w/2, y: cy + side/2)
            v3 = CGPoint(x: cx + w/2, y: cy - side/2)
        default: // right
            v1 = CGPoint(x: cx + w/2, y: cy)
            v2 = CGPoint(x: cx - w/2, y: cy + side/2)
            v3 = CGPoint(x: cx - w/2, y: cy - side/2)
        }
        
        path.move(to: v1)
        path.addLine(to: v2)
        path.addLine(to: v3)
        path.closeSubpath()
        
        let triangle = SKShapeNode(path: path)
        triangle.fillColor = .lightGray
        gridNode.addChild(triangle)
    }

    override func levelInitialized(_ game: AnyObject, state: YalooniqGameState, skView: SKView) {
        let game = game as! YalooniqGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: YalooniqGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for (p, hint) in game.pos2hint {
            let point = getHintPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: hint.num, s: state.pos2stateHint[p]!, point: point, nodeName: hintNodeName)
            addTriangle(in: CGRect(x: point.x + blockSize / 4, y: point.y - blockSize / 2, w: blockSize / 2, h: blockSize), dir: hint.dir)
        }
    }
    
    override func levelUpdated(from stateFrom: YalooniqGameState, to stateTo: YalooniqGameState) {
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
                    if b2 {
                        let squareNode = SKSpriteNode(color: s2 == .error ? .red : .white, size: coloredRectSize())
                        squareNode.position = point
                        squareNode.name = squareNodeName
                        gridNode.addChild(squareNode)
                    }
                }
                let (s3, s4) = (stateFrom.pos2stateHint[p], stateTo.pos2stateHint[p])
                if s3 != s4 {
                    removeNode(withName: hintNodeName)
                    addHint(n: stateFrom.game.pos2hint[p]!.num, s: s4!, point: getHintPoint(p: p), nodeName: hintNodeName)
                }
            }
        }
    }
}
