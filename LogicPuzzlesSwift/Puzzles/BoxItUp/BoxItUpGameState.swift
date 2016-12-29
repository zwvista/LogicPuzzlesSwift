//
//  BoxItUpGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BoxItUpGameState: CellsGameState, BoxItUpMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: BoxItUpGame {
        get {return getGame() as! BoxItUpGame}
        set {setGame(game: newValue)}
    }
    var objArray = [BoxItUpObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> BoxItUpGameState {
        let v = BoxItUpGameState(game: game)
        return setup(v: v)
    }
    func setup(v: BoxItUpGameState) -> BoxItUpGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: BoxItUpGame) {
        super.init(game: game);
        objArray = Array<BoxItUpObject>(repeating: Array<Bool>(repeating: false, count: 4), count: rows * cols)
        for r in 0..<rows {
            for c in 0..<cols {
                self[r, c] = game[r, c]
            }
        }
        for p in game.pos2hint.keys {
            pos2state[p] = .normal
        }
    }
    
    subscript(p: Position) -> BoxItUpObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> BoxItUpObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout BoxItUpGameMove) -> Bool {
        let p = move.p, dir = move.dir
        let p2 = p + BoxItUpGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) && !(game[p][dir] && self[p][dir]) else {return false}
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return true
    }
    
    private func updateIsSolved() {
        isSolved = true
        var rng = Set<Position>()
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                rng.insert(p)
                pos2node[p] = g.addNode(label: p.description)
            }
        }
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                for i in 0..<4 {
                    if !self[p + BoxItUpGame.offset2[i]][BoxItUpGame.dirs[i]] {
                        g.addEdge(source: pos2node[p]!, neighbor: pos2node[p + BoxItUpGame.offset[i]]!)
                    }
                }
            }
        }
        while !rng.isEmpty {
            let node = pos2node[rng.first!]!
            let nodesExplored = breadthFirstSearch(g, source: node)
            let area = rng.filter({p in nodesExplored.contains(p.description)})
            rng.subtract(area)
            let rng2 = area.filter({p in game.pos2hint[p] != nil})
            if rng2.count != 1 {
                for p in rng2 {
                    pos2state[p] = .normal
                }
                isSolved = false; continue
            }
            let p2 = rng2[0]
            let n1 = area.count, n2 = game.pos2hint[p2]!
            if n1 != n2 {isSolved = false; pos2state[p2] = .error; continue}
            var r2 = 0, r1 = rows, c2 = 0, c1 = cols
            for p in area {
                if r2 < p.row {r2 = p.row}
                if r1 > p.row {r1 = p.row}
                if c2 < p.col {c2 = p.col}
                if c1 > p.col {c1 = p.col}
            }
            let rs = r2 - r1 + 1, cs = c2 - c1 + 1;
            pos2state[p2] = rs * cs == n2 ? .complete : .error
            if rs * cs != n2 {isSolved = false}
        }
    }
}
