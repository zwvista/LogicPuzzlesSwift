//
//  LineSweeperGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LineSweeperGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: LineSweeperGame {
        get {return getGame() as! LineSweeperGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: LineSweeperDocument { return LineSweeperDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return LineSweeperDocument.sharedInstance }
    var objArray = [LineSweeperObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> LineSweeperGameState {
        let v = LineSweeperGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: LineSweeperGameState) -> LineSweeperGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: LineSweeperGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<LineSweeperObject>(repeating: LineSweeperObject(repeating: false, count: 4), count: rows * cols)
        for p in game.pos2hint.keys {
            pos2state[p] = .normal
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> LineSweeperObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> LineSweeperObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout LineSweeperGameMove) -> Bool {
        let p = move.p, dir = move.dir
        guard isValid(p: p) && !game.isHint(p: p) else {return false}
        let p2 = p + LineSweeperGame.offset[dir * 2], dir2 = (dir + 2) % 4
        guard isValid(p: p2) && !game.isHint(p: p2) else {return false}
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return true
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 4/LineSweeper

        Summary
        Draw a single loop, minesweeper style

        Description
        1. Draw a single closed looping path that never crosses itself or branches off.
        2. A number in a cell denotes how many of the 8 adjacent cells are passed
           by the loop.
        3. The loop can only go horizontally or vertically between cells, but
           not over the numbers.
        4. The loop doesn't need to cover all the board.
    */
    private func updateIsSolved() {
        isSolved = true
        for (p, n2) in game.pos2hint {
            var n1 = 0
            for os in LineSweeperGame.offset {
                let p2 = p + os
                guard isValid(p: p2) else {continue}
                var hasLine = false
                for b in self[p2] {
                    if b {hasLine = true}
                }
                if hasLine {n1 += 1}
            }
            pos2state[p] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 {isSolved = false}
        }
        guard isSolved else {return}
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p].filter({$0}).count
                switch n {
                case 0:
                    continue
                case 2:
                    pos2node[p] = g.addNode(p.description)
                default:
                    isSolved = false
                    return
                }
            }
        }
        for p in pos2node.keys {
            let o = self[p]
            for i in 0..<4 {
                guard o[i] else {continue}
                let p2 = p + LineSweeperGame.offset[i * 2]
                g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        let n1 = nodesExplored.count
        let n2 = pos2node.values.count
        if n1 != n2 {isSolved = false}
    }
}
