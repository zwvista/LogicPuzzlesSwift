//
//  ABCPathGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class ABCPathGameScene: GameScene<ABCPathGameState> {
    var gridNode: ABCPathGridNode {
        get {return getGridNode() as! ABCPathGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addCharacter(ch: Character, s: HintState, isHint: Bool, point: CGPoint, nodeName: String) {
        addLabel(text: String(ch), fontColor: s == .normal ? isHint ? .gray : .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }
    
    override func levelInitialized(_ game: AnyObject, state: ABCPathGameState, skView: SKView) {
        let game = game as! ABCPathGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: ABCPathGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))
        
        // add Characters
        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let ch = state[p]
                guard ch != " " else {continue}
                let nodeNameSuffix = "-\(p.row)-\(p.col)"
                let charNodeName = "char" + nodeNameSuffix
                let s = state.pos2state[p]!
                addCharacter(ch: ch, s: s, isHint: game[p] != " ", point: point, nodeName: charNodeName)
            }
        }
    }
    
    override func levelUpdated(from stateFrom: ABCPathGameState, to stateTo: ABCPathGameState) {
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let charNodeName = "char" + nodeNameSuffix
                let (ch1, ch2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p]!, stateTo.pos2state[p]!)
                guard ch1 != ch2 || s1 != s2 else {continue}
                if ch1 != " " {removeNode(withName: charNodeName)}
                if ch2 != " " {addCharacter(ch: ch2, s: s2, isHint: stateFrom.game[p] != " ", point: point, nodeName: charNodeName)}
            }
        }
    }
}
