//
//  ParkingLotGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class ParkingLotGameScene: GameScene<ParkingLotGameState> {
    var gridNode: ParkingLotGridNode {
        get { getGridNode() as! ParkingLotGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addHint(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(n), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: ParkingLotGameState, skView: SKView) {
        let game = game as! ParkingLotGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: ParkingLotGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
                
        for (p, n) in game.pos2hint {
            let point = gridNode.centerPoint(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNodeName = "hint" + nodeNameSuffix
            addHint(n: n, s: state.pos2stateHint[p]!, point: point, nodeName: hintNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: ParkingLotGameState, to stateTo: ParkingLotGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let markerNodeName = "marker" + nodeNameSuffix
                let hintNodeName = "hint" + nodeNameSuffix
                let carNodeName = "car" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2stateHint[p], stateTo.pos2stateHint[p])
                let (s3, s4) = (stateFrom.pos2stateAllowed[p], stateTo.pos2stateAllowed[p])
                if o1 != o2 || s3 != s4 {
                    switch o1 {
                    case .empty:
                        break
                    case .marker:
                        removeNode(withName: markerNodeName)
                    default:
                        removeNode(withName: carNodeName)
                    }
                    switch o2 {
                    case .empty:
                        break
                    case .marker:
                        addDotMarker(point: point, nodeName: markerNodeName)
                    default:
                        addImage(imageNamed: "car_\(String(describing: o2))", color: .green, colorBlendFactor: s4! == .normal ? 0.0 : 0.5, point: point, nodeName: carNodeName)
                    }
                }
                if s1 != s2 || s1 != nil && o1 != o2 {
                    removeNode(withName: hintNodeName)
                    addHint(n: stateFrom.game.pos2hint[p]!, s: s2!, point: point, nodeName: hintNodeName)
                }
            }
        }
    }
}
