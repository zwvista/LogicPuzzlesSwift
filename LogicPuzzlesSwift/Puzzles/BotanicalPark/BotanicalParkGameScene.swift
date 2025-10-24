//
//  BotanicalParkGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class BotanicalParkGameScene: GameScene<BotanicalParkGameState> {
    var gridNode: BotanicalParkGridNode {
        get { getGridNode() as! BotanicalParkGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addArrow(n: Int, s: AllowedObjectState, point: CGPoint, nodeName: String) {
        addImage(imageNamed: getArrowImageName(n: n), color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: BotanicalParkGameState, skView: SKView) {
        let game = game as! BotanicalParkGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: BotanicalParkGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let arrowNodeName = "arrow" + nodeNameSuffix
                switch state[p] {
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                case let .arrow(s):
                    let point = gridNode.centerPoint(p: p)
                    let n = game.pos2arrow[p]!
                    addArrow(n: n, s: s, point: point, nodeName: arrowNodeName)
                default:
                    break
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: BotanicalParkGameState, to stateTo: BotanicalParkGameState) {
        func removeHint(p: Position) {
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            removeNode(withName: hintNodeName)
        }
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let plantNodeName = "plant" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let forbiddenNodeName = "forbidden" + nodeNameSuffix
                let arrowNodeName = "arrow" + nodeNameSuffix
                let (o1, o2) = (stateFrom[r, c], stateTo[r, c])
                guard String(describing: o1) != String(describing: o2) else {continue}
                switch o1 {
                case .forbidden:
                    removeNode(withName: forbiddenNodeName)
                case .plant:
                    removeNode(withName: plantNodeName)
                case .arrow:
                    removeNode(withName: arrowNodeName)
                case .marker:
                    removeNode(withName: markerNodeName)
                default:
                    break
                }
                switch o2 {
                case .forbidden:
                    addForbiddenMarker(point: point, nodeName: forbiddenNodeName)
                case let .plant(s):
                    addImage(imageNamed: "tree", color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: plantNodeName)
                case let .arrow(s):
                    let n = stateTo.game.pos2arrow[p]!
                    addArrow(n: n, s: s, point: point, nodeName: arrowNodeName)
                case .marker:
                    addDotMarker(point: point, nodeName: markerNodeName)
                default:
                    break
                }                
            }
        }
    }
}
