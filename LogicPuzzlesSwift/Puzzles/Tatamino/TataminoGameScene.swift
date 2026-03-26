//
//  TataminoGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class TataminoGameScene: GameScene<TataminoGameState> {
    var gridNode: TataminoGridNode {
        get { getGridNode() as! TataminoGridNode }
        set { setGridNode(gridNode: newValue) }
    }
    
    func addCharacter(ch: Character, s: HintState, isHint: Bool, point: CGPoint, nodeName: String) {
        addLabel(text: String(ch), fontColor: isHint ? .gray : s == .normal ? .white : s == .complete ? .green : .red, point: point, nodeName: nodeName)
    }

    override func levelInitialized(_ game: AnyObject, state: TataminoGameState, skView: SKView) {
        let game = game as! TataminoGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // add Grid
        let offset:CGFloat = 0.5
        addGrid(gridNode: TataminoGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset))

        for r in 0..<game.rows + 1 {
            for c in 0..<game.cols + 1 {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                func f(p2: Position) -> Character {
                    !game.isValid(p: p2) ? "." : game[p2]
                }
                let ch = f(p2: p)
                func g(p2: Position) -> Bool {
                    let ch2 = f(p2: p2)
                    return ch != ch2 && (ch == "." || ch2 == "." || ch != " " && ch2 != " ")
                }
                if g(p2: Position(r - 1, c)) { addHorzLine(objType: .line, color: .white, point: point, nodeName: "line") }
                if g(p2: Position(r, c - 1)) { addVertLine(objType: .line, color: .white, point: point, nodeName: "line") }
                guard r < game.rows && c < game.cols else {continue}
                let nodeNameSuffix = "-\(r)-\(c)"
                let charNodeName = "char" + nodeNameSuffix
                if ch != " " {
                    addCharacter(ch: ch, s: state.pos2state[p] ?? .normal, isHint: game[p] != " ", point: point, nodeName: charNodeName)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: TataminoGameState, to stateTo: TataminoGameState) {
        let game = stateFrom.game
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                let p = Position(r, c)
                let point = gridNode.centerPoint(p: p)
                let nodeNameSuffix = "-\(r)-\(c)"
                let horzLineNodeName = "horzLine" + nodeNameSuffix
                let vertlineNodeName = "vertline" + nodeNameSuffix
                func f(state: TataminoGameState, p2: Position) -> Bool {
                    let (ch, ch2) = (state[p], state[p2])
                    return ch != ch2 && ch != " " && ch2 != " "
                }
                if r > 0 {
                    let p2 = Position(r - 1, c)
                    let (b1, b2) = (f(state: stateFrom, p2: p2), f(state: stateTo, p2: p2))
                    if b1 != b2 {
                        if b1 { removeNode(withName: horzLineNodeName) }
                        if b2 { addHorzLine(objType: .line, color: .yellow, point: point, nodeName: horzLineNodeName) }
                    }
                }
                if (c > 0) {
                    let p2 = Position(r, c - 1)
                    let (b1, b2) = (f(state: stateFrom, p2: p2), f(state: stateTo, p2: p2))
                    if b1 != b2 {
                        if b1 { removeNode(withName: vertlineNodeName) }
                        if b2 { addVertLine(objType: .line, color: .yellow, point: point, nodeName: vertlineNodeName) }
                    }
                }
                let charNodeName = "char" + nodeNameSuffix
                let (ch1, ch2) = (stateFrom[p], stateTo[p])
                let (s1, s2) = (stateFrom.pos2state[p], stateTo.pos2state[p])
                if ch1 != ch2 || s1 != s2 {
                    if (ch1 != " ") {
                        removeNode(withName: charNodeName)
                    }
                    if (ch2 != " ") {
                        addCharacter(ch: ch2, s: stateTo.pos2state[p] ?? .normal, isHint: game[p] != " ", point: point, nodeName: charNodeName)
                    }
                }
            }
        }
    }
}
