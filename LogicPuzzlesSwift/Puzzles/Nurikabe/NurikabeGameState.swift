//
//  NurikabeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NurikabeGameState: CellsGameState {
    var game: NurikabeGame {return gameBase as! NurikabeGame}
    var objArray = [NurikabeObject]()
    var options: NurikabeGameProgress { return NurikabeDocument.sharedInstance.gameProgress }
    
    override func copy() -> NurikabeGameState {
        let v = NurikabeGameState(game: gameBase)
        return setup(v: v)
    }
    func setup(v: NurikabeGameState) -> NurikabeGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: CellsGameBase) {
        super.init(game: game)
        let game = game as! NurikabeGame
        objArray = Array<NurikabeObject>(repeating: NurikabeObject(), count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
    }
    
    subscript(p: Position) -> NurikabeObject {
        get {
            return objArray[p.row * cols + p.col]
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
        let markerOption = NurikabeMarkerOptions(rawValue: options.markerOption)
        func f(o: NurikabeObject) -> NurikabeObject {
            switch o {
            case .empty:
                return markerOption == .markerBeforeWall ? .marker : .wall
            case .wall:
                return markerOption == .markerAfterWall ? .marker : .empty
            case .marker:
                return markerOption == .markerBeforeWall ? .wall : .empty
            case .hint:
                return o
            }
        }
        move.obj = f(o: self[move.p])
        return setObject(move: &move)
    }
    
    private func updateIsSolved() {
        isSolved = true
        rule2x2:
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                var is2x2 = true
                for os in NurikabeGame.offset2 {
                    guard case .wall = self[p + os] else {is2x2 = false; break}
                }
                if is2x2 {isSolved = false; break rule2x2}
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
        for (p, n1) in game.pos2hint {
            let nodesExplored = breadthFirstSearch(g, source: pos2node[p]!)
            let n2 = nodesExplored.count
            var m = 0
            for p2 in game.pos2hint.keys {
                if nodesExplored.contains(p2.description) {m += 1}
            }
            let s: HintState = m > 1 ? .normal : n1 == n2 ? .complete : .error
            self[p] = .hint(state: s)
            if s != .complete {isSolved = false}
        }
    }
}
