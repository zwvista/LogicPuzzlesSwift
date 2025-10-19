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
                let point = gridNode.gridPosition(p: p)
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
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                let n = stateFrom.game.pos2hint[p]
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                guard o1 != o2 || s1 != s2 else {continue}
                removeNode(withName: tileNodeName)
                func f(imageName: String) {
                    addImage(imageNamed: imageName, color: .red, colorBlendFactor: s2 == .normal ? 0.0 : 0.5, point: point, nodeName: tileNodeName)
                }
                if 1..<stateFrom.rows - 1 ~= r && 1..<stateFrom.cols - 1 ~= c {
                    switch o2 {
                    case .gem:
                        f(imageName: "bullet_ball_glass_blue")
                    case .pebble:
                        f(imageName: "bullet_ball_glass_grey")
                    case .marker:
                        addDotMarker(point: point, nodeName: tileNodeName)
                    default:
                        break
                    }
                } else {
                    addHint(n: n!, s: s2 ?? .normal, point: point, nodeName: tileNodeName)
                }
            }
        }
    }
}
