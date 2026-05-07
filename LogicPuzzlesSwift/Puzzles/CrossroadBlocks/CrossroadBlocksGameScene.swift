//
//  CrossroadBlocksGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class CrossroadBlocksGameScene: GameScene<CrossroadBlocksGameState> {
    var gridNode: CrossroadBlocksGridNode {
        get { getGridNode() as! CrossroadBlocksGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, isBlack: Bool, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? isBlack ? .white : .black : s == .complete ? .green : .red, point: point, nodeName: nodeName, size: CGSize(width: gridNode.blockSize, height: gridNode.blockSize / 2))
    }
    
    func getHintPoint(p: Position) -> CGPoint {
        let offset: CGFloat = 0.5
        let x = (CGFloat(p.col) + CGFloat(0.25)) * gridNode.blockSize + offset
        let y = -((CGFloat(p.row) + CGFloat(0.5)) * gridNode.blockSize + offset)
        return CGPoint(x: x, y: y)
    }
    
    func addTriangle(in rect: CGRect, dir: Int, color: UIColor) {
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
        triangle.fillColor = color
        gridNode.addChild(triangle)
    }

    override func levelInitialized(_ game: AnyObject, state: CrossroadBlocksGameState, skView: SKView) {
        let game = game as! CrossroadBlocksGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: CrossroadBlocksGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for (p, hint) in game.pos2hint {
            let (isBlack, n, dir) = (hint.isBlack, hint.num, hint.dir)
            let point2 = gridNode.centerPoint(p: p)
            if isBlack {
                let rectNode = SKShapeNode(rectOf: coloredRectSize())
                rectNode.name = "block"
                rectNode.position = point2
                rectNode.strokeColor = .lightGray
                rectNode.lineWidth = 4
                gridNode.addChild(rectNode)
            } else {
                addBlock(color: .white, point: point2, nodeName: "block")
            }
            guard n != CrossroadBlocksGame.PUZ_UNKNOWN else {continue}
            let point = getHintPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, isBlack: isBlack, s: state.pos2state[p]!, point: point, nodeName: hintNodeName)
            addTriangle(in: CGRect(x: point.x + blockSize / 4, y: point.y - blockSize / 2, w: blockSize / 2, h: blockSize), dir: dir, color: isBlack ? .white : .black)
        }
    }
    
    override func levelUpdated(from stateFrom: CrossroadBlocksGameState, to stateTo: CrossroadBlocksGameState) {
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
                if s1 != s2 {
                    let hint = game.pos2hint[p]!
                    removeNode(withName: hintNodeName)
                    addHint(n: hint.num, isBlack: hint.isBlack, s: s2!, point: getHintPoint(p: p), nodeName: hintNodeName)
                }
            }
        }
    }
}
