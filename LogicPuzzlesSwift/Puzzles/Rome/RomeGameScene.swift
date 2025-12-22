//
//  RomeGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class RomeGameScene: GameScene<RomeGameState> {
    var gridNode: RomeGridNode {
        get { getGridNode() as! RomeGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addObject(o: RomeObject, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        func f(o: RomeObject) -> String {
            switch o {
            case .up:
                return "arrow_bw_up"
            case .right:
                return "arrow_bw_right"
            case .down:
                return "arrow_bw_down"
            case .left:
                return "arrow_bw_left"
            default:
                return "rome"
            }
        }
        addImage(imageNamed: f(o: o), color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: RomeGameState, skView: SKView) {
        let game = game as! RomeGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: RomeGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
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
        
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let objectNodeName = "object" + nodeNameSuffix
                let o = state[p]
                guard o != .empty else {continue}
                addObject(o: o, s: state.pos2state[p] ?? .normal, point: point, nodeName: objectNodeName)
                addCircleMarker(color: .white, point: point, nodeName: "marker")
            }
        }
    }
    
    override func levelUpdated(from stateFrom: RomeGameState, to stateTo: RomeGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let objectNodeName = "object" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p] ?? .normal, stateTo.pos2state[p] ?? .normal)
                guard o1 != o2 || s1 != s2 else {continue}
                if o1 != .empty { removeNode(withName: objectNodeName) }
                if o2 != .empty { addObject(o: o2, s: s2, point: point, nodeName: objectNodeName) }
            }
        }
    }
}
