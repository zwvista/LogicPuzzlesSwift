//
//  LiarLiarGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class LiarLiarGameScene: GameScene<LiarLiarGameState> {
    var gridNode: LiarLiarGridNode {
        get { getGridNode() as! LiarLiarGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(p: Position, n: Int, s: HintState) {
        let point = gridNode.centerPoint(p: p)
        let nodeNameSuffix = "-\(p.row)-\(p.col)"
        let hintNodeName = "hint" + nodeNameSuffix
        addLabel(text: String(n), fontColor: s == .complete ? .green : .red, point: point, nodeName: hintNodeName, sampleText: "10")
    }

    override func levelInitialized(_ game: AnyObject, state: LiarLiarGameState, skView: SKView) {
        let game = game as! LiarLiarGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: LiarLiarGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
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
            guard case .hint(state: let s) = state[p] else {continue}
            addHint(p: p, n: n, s: s)
        }
    }
    
    override func levelUpdated(from stateFrom: LiarLiarGameState, to stateTo: LiarLiarGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let markedNodeName = "marked" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                guard String(describing: o1) != String(describing: o2) else {continue}
                switch o1 {
                case .forbidden:
                    removeNode(withName: forbiddenNodeName)
                case .hint:
                    removeNode(withName: hintNodeName)
                case .marked:
                    removeNode(withName: markedNodeName)
                case .marker:
                    removeNode(withName: markerNodeName)
                default:
                    break
                }
                switch o2 {
                case .forbidden:
                    addDotMarker2(color: .red, point: point, nodeName: forbiddenNodeName)
                case .hint(state: let s):
                    addHint(p: p, n: stateFrom.game.pos2hint[p]!, s: s)
                case .marked(state: let s):
                    let markedNode = SKSpriteNode(color: s == .error ? .red : .lightGray, size: coloredRectSize())
                    markedNode.position = point
                    markedNode.name = markedNodeName
                    gridNode.addChild(markedNode)
                case .marker:
                    addCircleMarker(color: .white, point: point, nodeName: markerNodeName)
                default:
                    break
                }
            }
        }
    }
}
