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
    var objArray = [BoxItUpDotObject]()
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
        objArray = Array<BoxItUpDotObject>(repeating: Array<BoxItUpObject>(repeating: .empty, count: 4), count: rows * cols)
        for (p, n) in game.pos2hint {
            pos2state[p] = n == 0 ? .complete : .normal
        }
    }
    
    subscript(p: Position) -> BoxItUpDotObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> BoxItUpDotObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout BoxItUpGameMove) -> Bool {
        var changed = false
        func f(o1: inout BoxItUpObject, o2: inout BoxItUpObject) {
            if o1 != move.obj {
                changed = true
                o1 = move.obj
                o2 = move.obj
                // updateIsSolved() cannot be called here
                // self[p] will not be updated until the function returns
            }
        }
        let p = move.p
        let dir = move.dir, dir2 = (dir + 2) % 4
        f(o1: &self[p][dir], o2: &self[p + BoxItUpGame.offset[dir]][dir2])
        if changed {updateIsSolved()}
        return changed
    }
    
    func switchObject(move: inout BoxItUpGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: BoxItUpObject) -> BoxItUpObject {
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
        for (p, n2) in game.pos2hint {
            var n1 = 0
            if self[p][1] == .line {n1 += 1}
            if self[p][2] == .line {n1 += 1}
            if self[p + Position(1, 1)][0] == .line {n1 += 1}
            if self[p + Position(1, 1)][3] == .line {n1 += 1}
            pos2state[p] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 {isSolved = false}
        }
        guard isSolved else {return}
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p].filter({$0 == .line}).count
                switch n {
                case 0:
                    continue
                case 2:
                    pos2node[p] = g.addNode(label: p.description)
                default:
                    isSolved = false
                    return
                }
            }
        }
        for p in pos2node.keys {
            let dotObj = self[p]
            for i in 0..<4 {
                guard dotObj[i] == .line else {continue}
                let p2 = p + BoxItUpGame.offset[i]
                g.addEdge(source: pos2node[p]!, neighbor: pos2node[p2]!)
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.values.first!)
        let n1 = nodesExplored.count
        let n2 = pos2node.values.count
        if n1 != n2 {isSolved = false}
    }
}
