//
//  BattleShipsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BattleShipsGameState: CellsGameState, BattleShipsMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: BattleShipsGame {
        get {return getGame() as! BattleShipsGame}
        set {setGame(game: newValue)}
    }
    var objArray = [BattleShipsObject]()
    var row2state = [HintState]()
    var col2state = [HintState]()
    
    override func copy() -> BattleShipsGameState {
        let v = BattleShipsGameState(game: game)
        return setup(v: v)
    }
    func setup(v: BattleShipsGameState) -> BattleShipsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.row2state = row2state
        v.col2state = col2state
        return v
    }
    
    required init(game: BattleShipsGame) {
        super.init(game: game);
        objArray = Array<BattleShipsObject>(repeating: BattleShipsObject(), count: rows * cols)
        row2state = Array<HintState>(repeating: .normal, count: rows)
        col2state = Array<HintState>(repeating: .normal, count: cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> BattleShipsObject {
        get {
            return objArray[p.row * cols + p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> BattleShipsObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout BattleShipsGameMove) -> Bool {
        let p = move.p
        guard isValid(p: p) && self[p] != move.obj else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout BattleShipsGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: BattleShipsObject) -> BattleShipsObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .cloud
            case .cloud:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .cloud : .empty
            }
        }
        let p = move.p
        guard isValid(p: p) else {return false}
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            var n1 = 0
            let n2 = game.row2hint[r]
            for c in 0..<cols {
                if self[r, c] == .cloud {n1 += 1}
            }
            row2state[r] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 {isSolved = false}
        }
        for c in 0..<cols {
            var n1 = 0
            let n2 = game.col2hint[c]
            for r in 0..<rows {
                if self[r, c] == .cloud {n1 += 1}
            }
            col2state[c] = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 {isSolved = false}
        }
        guard isSolved else {return}
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p] == .cloud else {continue}
                let node = g.addNode(label: p.description)
                pos2node[p] = node
            }
        }
        for (p, node) in pos2node {
            for os in BattleShipsGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(source: node, neighbor: node2)
            }
        }
        while pos2node.count > 0 {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.values.first!)
            var r2 = 0, r1 = rows, c2 = 0, c1 = cols
            for node in nodesExplored {
                let p = pos2node.filter{$1.label == node}.first!.key
                pos2node.remove(at: pos2node.index(forKey: p)!)
                if r2 < p.row {r2 = p.row}
                if r1 > p.row {r1 = p.row}
                if c2 < p.col {c2 = p.col}
                if c1 > p.col {c1 = p.col}
            }
            let rs = r2 - r1 + 1, cs = c2 - c1 + 1;
            if !(rs >= 2 && cs >= 2 && rs * cs == nodesExplored.count) {
                isSolved = false
                return
            }
        }
    }
}
