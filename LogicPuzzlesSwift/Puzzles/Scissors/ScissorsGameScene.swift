//
//  ScissorsGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class ScissorsGameScene: GameScene<ScissorsGameState> {
    var gridNode: ScissorsGridNode {
        get { getGridNode() as! ScissorsGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addNumber(ch: Character, s: HintState, point: CGPoint, nodeName: String) {
        addLabel(text: String(ch), fontColor: s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: ScissorsGameState, skView: SKView) {
        let game = game as! ScissorsGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: ScissorsGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
                
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let tileNodeName = "tile" + nodeNameSuffix
                let ch = game[p]
                guard ch != " " else {continue}
                addNumber(ch: ch, s: state.pos2state[p]!, point: point, nodeName: tileNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: ScissorsGameState, to stateTo: ScissorsGameState) {
        let game = stateFrom.game
        var rng = Set<Position>()
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let nodeNameSuffix = "-\(r)-\(c)"
                let tileNodeName = "tile" + nodeNameSuffix
                let (o1, o2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                guard o1 != o2 || s1 != s2 else {continue}
                if o1 != " " { removeNode(withName: tileNodeName) }
                func addSlash(p1: Position, p2: Position) {
                    let pathToDraw = CGMutablePath()
                    pathToDraw.move(to: gridNode.cornerPoint(p: p1))
                    pathToDraw.addLine(to: gridNode.cornerPoint(p: p2))
                    let slashNode = SKShapeNode(path:pathToDraw)
                    slashNode.strokeColor = .green
                    slashNode.lineWidth = 4
                    slashNode.name = tileNodeName
                    gridNode.addChild(slashNode)
                    rng.insert(p1)
                    rng.insert(p2)
                }
                switch o2 {
                case ScissorsGame.PUZ_BACK_SLASH:
                    addSlash(p1: p + ScissorsGame.offset2[1], p2: p + ScissorsGame.offset2[2])
                case ScissorsGame.PUZ_FRONT_SLASH:
                    addSlash(p1: p, p2: p + ScissorsGame.offset2[3])
                case " ":
                    break
                default:
                    let point = gridNode.centerPoint(p: p)
                    addNumber(ch: o2, s: s2!, point: point, nodeName: tileNodeName)
                }
            }
        }
    }
}
