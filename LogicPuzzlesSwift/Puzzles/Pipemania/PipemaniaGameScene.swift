//
//  PipemaniaGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class PipemaniaGameScene: GameScene<PipemaniaGameState> {
    var gridNode: PipemaniaGridNode {
        get { getGridNode() as! PipemaniaGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addPipe(o: PipemaniaObject, point: CGPoint, nodeName: String) {
        let imageName = switch o {
        case .upright: "pipe_1"
        case .downright: "pipe_2"
        case .leftdown: "pipe_3"
        case .leftup: "pipe_4"
        case .horizontal: "pipe_horizontal"
        case .vertical: "pipe_vertical"
        default: "pipe_cross"
        }
        addImage(imageNamed: imageName, color: .red, colorBlendFactor: 0.0, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: PipemaniaGameState, skView: SKView) {
        let game = game as! PipemaniaGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: PipemaniaGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Hints
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let o = state[p]
                if o != .empty {
                    addPipe(o: o, point: point, nodeName: "tile")
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: PipemaniaGameState, to stateTo: PipemaniaGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                guard o1 != o2 else {continue}
                if o1 != .empty { removeNode(withName: tileNodeName) }
                if o2 != .empty { addPipe(o: o2, point: point, nodeName: tileNodeName) }
            }
        }
    }
}
