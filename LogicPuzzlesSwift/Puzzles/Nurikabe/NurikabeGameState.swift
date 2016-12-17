//
//  NurikabeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NurikabeGameState: CellsGameState, NurikabeMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: NurikabeGame {
        get {return getGame() as! NurikabeGame}
        set {setGame(game: newValue)}
    }
    var objArray = [NurikabeObject]()
    
    override func copy() -> NurikabeGameState {
        let v = NurikabeGameState(game: game)
        return setup(v: v)
    }
    func setup(v: NurikabeGameState) -> NurikabeGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: NurikabeGame) {
        super.init(game: game);
        objArray = Array<NurikabeObject>(repeating: NurikabeObject(), count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
    }
    
    subscript(p: Position) -> NurikabeObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> NurikabeObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout NurikabeGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 {return false}
        // guard case .hint != o1 else {return false} // syntax error
        // guard !(.hint ~= o1) else {return false} // syntax error
        guard String(describing: o1) != String(describing: o2) else {return false}
        self[p] = o2
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout NurikabeGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: NurikabeObject) -> NurikabeObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .wall
            case .wall:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .wall : .empty
            case .hint:
                return o
            }
        }
        move.obj = f(o: self[move.p])
        return setObject(move: &move)
    }
    
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows - 1 {
            rule2x2:
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                for os in NurikabeGame.offset2 {
                    guard case .wall = self[p + os] else {continue rule2x2}
                }
                isSolved = false
            }
        }
        let g = Graph()
        var pos2node = [Position: Node]()
        var rngWalls = [Position]()
        var rngEmpty = [Position]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                pos2node[p] = g.addNode(label: p.description)
                switch self[p] {
                case .wall:
                    rngWalls.append(p)
                default:
                    rngEmpty.append(p)
                }
            }
        }
        for p in rngWalls {
            for os in NurikabeGame.offset {
                let p2 = p + os
                if rngWalls.contains(p2) {
                    g.addEdge(source: pos2node[p]!, neighbor: pos2node[p2]!)
                }
            }
        }
        for p in rngEmpty {
            for os in NurikabeGame.offset {
                let p2 = p + os
                if rngEmpty.contains(p2) {
                    g.addEdge(source: pos2node[p]!, neighbor: pos2node[p2]!)
                }
            }
        }
        if rngWalls.isEmpty {
            isSolved = false
        } else {
            let nodesExplored = breadthFirstSearch(g, source: pos2node[rngWalls.first!]!)
            if rngWalls.count != nodesExplored.count {isSolved = false}
        }
        while !rngEmpty.isEmpty {
            let node = pos2node[rngEmpty.first!]!
            let nodesExplored = breadthFirstSearch(g, source: node)
            rngEmpty = rngEmpty.filter({p in !nodesExplored.contains(p.description)})
            let n2 = nodesExplored.count
            var rng = [Position]()
            for p in game.pos2hint.keys {
                if nodesExplored.contains(p.description) {
                    rng.append(p)
                }
            }
            switch rng.count {
            case 0:
                isSolved = false
            case 1:
                let p = rng.first!
                let n1 = game.pos2hint[p]!
                let s: HintState = n1 == n2 ? .complete : .error
                self[p] = .hint(state: s)
                if s != .complete {isSolved = false}
            default:
                for p in rng {
                    self[p] = .hint(state: .normal)
                }
                isSolved = false
            }
        }
    }
}
