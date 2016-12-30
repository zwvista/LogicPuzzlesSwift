//
//  BoxItAroundGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BoxItAroundGameState: GridGameState, BoxItAroundMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: BoxItAroundGame {
        get {return getGame() as! BoxItAroundGame}
        set {setGame(game: newValue)}
    }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> BoxItAroundGameState {
        let v = BoxItAroundGameState(game: game)
        return setup(v: v)
    }
    func setup(v: BoxItAroundGameState) -> BoxItAroundGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: BoxItAroundGame) {
        super.init(game: game);
        objArray = game.objArray
        for p in game.pos2hint.keys {
            pos2state[p] = .normal
        }
    }
    
    subscript(p: Position) -> GridDotObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> GridDotObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout BoxItAroundGameMove) -> Bool {
        var changed = false
        func f(o1: inout GridLineObject, o2: inout GridLineObject) {
            if o1 != move.obj {
                changed = true
                o1 = move.obj
                o2 = move.obj
                // updateIsSolved() cannot be called here
                // self[p] will not be updated until the function returns
            }
        }
        let dir = move.dir, dir2 = (dir + 2) % 4
        let p = move.p, p2 = p + BoxItAroundGame.offset[dir]
        guard isValid(p: p2) && game[p][dir] != .line else {return false}
        f(o1: &self[p][dir], o2: &self[p2][dir2])
        if changed {updateIsSolved()}
        return changed
    }
    
    func switchObject(move: inout BoxItAroundGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: GridLineObject) -> GridLineObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .line
            case .line:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .line : .empty
            }
        }
        let o = f(o: self[move.p][move.dir])
        move.obj = o
        return setObject(move: &move)
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
                    if self[p + BoxItUpGame.offset2[i]][BoxItUpGame.dirs[i]] != .line {
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
            var r2 = 0, r1 = rows, c2 = 0, c1 = cols
            for p in area {
                if r2 < p.row {r2 = p.row}
                if r1 > p.row {r1 = p.row}
                if c2 < p.col {c2 = p.col}
                if c1 > p.col {c1 = p.col}
            }
            let rs = r2 - r1 + 1, cs = c2 - c1 + 1;
            func hasLine() -> Bool {
                for r in r1...r2 {
                    for c in c1...c2 {
                        let dotObj = self[r + 1, c + 1]
                        if r < r2 && dotObj[3] == .line || c < c2 && dotObj[0] == .line {return true}
                    }
                }
                return false
            }
            pos2state[p2] = rs * cs == n1 && rs + cs == n2 && !hasLine() ? .complete : .error
            if pos2state[p2] != .complete {isSolved = false}
        }
    }
}
