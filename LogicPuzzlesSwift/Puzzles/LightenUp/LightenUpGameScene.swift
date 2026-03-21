//
//  LightenUpGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class LightenUpGameScene: GameScene<LightenUpGameState> {
    var gridNode: LightenUpGridNode {
        get { getGridNode() as! LightenUpGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addWallNumber(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .black : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: LightenUpGameState, skView: SKView) {
        let game = game as! LightenUpGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: LightenUpGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // addWalls
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                guard state[p].objType == .wall else {continue}
                let n = game.pos2hint[p]!
                let point = gridNode.centerPoint(p: p)
                addBlock(color: .white, point: point, nodeName: "wall")
                guard n >= 0 else {continue}
                let nodeNameSuffix = "-\(r)-\(c)"
                let wallNumberNodeName = "wallNumber" + nodeNameSuffix
                let s = state.pos2stateHint[p]!
                addWallNumber(n: n, s: s, point: point, nodeName: wallNumberNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: LightenUpGameState, to stateTo: LightenUpGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let lightCellNodeName = "lightCell" + nodeNameSuffix
                let lightbulbNodeName = "lightbulb" + nodeNameSuffix
                let markerNodeName = "marker" + nodeNameSuffix
                let wallNumberNodeName = "wallNumber" + nodeNameSuffix
                let (x, y) = (stateFrom[p].lightness, stateTo[p].lightness)
                if x > 0 && y == 0 {
                    removeNode(withName: lightCellNodeName)
                } else if x == 0 && y > 0 {
                    addBlock(color: .yellow, point: point, nodeName: lightCellNodeName)
                }
                let (o1, o2) = (stateFrom[p].objType, stateTo[p].objType)
                let (s1, s2) = (stateFrom.pos2stateHint[p], stateTo.pos2stateHint[p])
                let (s3, s4) = (stateFrom.pos2stateAllowed[p], stateTo.pos2stateAllowed[p])
                guard o1 != o2 || s1 != s2 || s3 != s4 else {continue}
                switch o1 {
                case .lightbulb:
                    removeNode(withName: lightbulbNodeName)
                case .marker:
                    removeNode(withName: markerNodeName)
                case .wall:
                    removeNode(withName: wallNumberNodeName)
                default:
                    break
                }
                switch o2 {
                case .lightbulb:
                    addImage(imageNamed: "lightbulb_on", color: .red, colorBlendFactor: s4 == .normal ? 0.0 : 0.2, point: point, nodeName: lightbulbNodeName)
                case .marker:
                    addDotMarker(point: point, nodeName: markerNodeName)
                case .wall:
                    let n = stateTo.game.pos2hint[p]!
                    addWallNumber(n: n, s: s2!, point: point, nodeName: wallNumberNodeName)
                default:
                    break
                }
            }
        }
    }
}
