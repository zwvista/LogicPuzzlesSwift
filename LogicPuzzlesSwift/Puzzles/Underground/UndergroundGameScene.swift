//
//  UndergroundGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class UndergroundGameScene: GameScene<UndergroundGameState> {
    var gridNode: UndergroundGridNode {
        get { getGridNode() as! UndergroundGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addObject(o: UndergroundObject, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        let imageName = switch o {
        case .up: "stairs_up"
        case .right: "stairs_right"
        case .down: "stairs_down"
        case .left: "stairs_left"
        default: "stairs_up"
        }
        addImage(imageNamed: imageName, color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: UndergroundGameState, skView: SKView) {
        let game = game as! UndergroundGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: UndergroundGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
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
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let o = state[p]
                switch o {
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                case .up, .right, .down, .left:
                    addObject(o: o, s: state.pos2state[p]!, point: point, nodeName: objectNodeName)
                default:
                    break
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: UndergroundGameState, to stateTo: UndergroundGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let objectNodeName = "object" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p] ?? .normal, stateTo.pos2state[p] ?? .normal)
                guard o1 != o2 || s1 != s2 else {continue}
                switch o1 {
                case .forbidden:
                    removeNode(withName: forbiddenNodeName)
                case .marker:
                    removeNode(withName: markerNodeName)
                case .up, .right, .down, .left:
                    removeNode(withName: objectNodeName)
                default:
                    break
                }
                switch o2 {
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                case .marker:
                    addDotMarker(point: point, nodeName: markerNodeName)
                case .up, .right, .down, .left:
                    addObject(o: o2, s: s2, point: point, nodeName: objectNodeName)
                default:
                    break
                }
            }
        }
    }
}
