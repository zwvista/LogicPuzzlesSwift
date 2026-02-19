//
//  GemsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class GemsGameScene: GameScene<GemsGameState> {
    var gridNode: GemsGridNode {
        get { getGridNode() as! GemsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: GemsGameState, skView: SKView) {
        let game = game as! GemsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: GemsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Numbers
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let n = game.pos2hint[p]
                guard let n else {continue}
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let tileNodeName = "tile" + nodeNameSuffix
                addHint(n: n, s: .normal, point: point, nodeName: tileNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: GemsGameState, to stateTo: GemsGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                let n = stateFrom.game.pos2hint[p]
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2stateAllowed[p], stateTo.pos2stateAllowed[p])
                let (s3, s4) = (stateFrom.pos2stateHint[p], stateTo.pos2stateHint[p])
                guard o1 != o2 || s1 != s2 || s3 != s4 else {continue}
                removeNode(withName: tileNodeName)
                func f(imageName: String, s: AllowedObjectState) {
                    addImage(imageNamed: imageName, color: .red, colorBlendFactor: s == .normal ? 0.0 : 0.5, point: point, nodeName: tileNodeName)
                }
                switch o2 {
                case .gem:
                    f(imageName: "bullet_ball_glass_blue", s: s2!)
                case .hint:
                    addHint(n: n!, s: s4!, point: point, nodeName: tileNodeName)
                case .marker:
                    addDotMarker(point: point, nodeName: tileNodeName)
                case .pebble:
                    f(imageName: "bullet_ball_glass_grey", s: .normal)
                default:
                    break
                }
            }
        }
    }
}
