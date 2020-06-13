//
//  NurikabeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NurikabeGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: NurikabeGame {
        get {getGame() as! NurikabeGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: NurikabeDocument { return NurikabeDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return NurikabeDocument.sharedInstance }
    var objArray = [NurikabeObject]()
    
    override func copy() -> NurikabeGameState {
        let v = NurikabeGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: NurikabeGameState) -> NurikabeGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: NurikabeGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<NurikabeObject>(repeating: NurikabeObject(), count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
        updateIsSolved()
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
    
    /*
        iOS Game: Logic Games/Puzzle Set 1/Nurikabe

        Summary
        Draw a continuous wall that divides gardens as big as the numbers

        Description
        1. Each number on the grid indicates a garden, occupying as many tiles
           as the number itself.
        2. Gardens can have any form, extending horizontally and vertically, but
           can't extend diagonally.
        3. The garden is separated by a single continuous wall. This means all
           wall tiles on the board must be connected horizontally or vertically.
           There can't be isolated walls.
        4. You must find and mark the wall following these rules:
        5. All the gardens in the puzzle are numbered at the start, there are no
           hidden gardens.
        6. A wall can't go over numbered squares.
        7. The wall can't form 2*2 squares.
    */
    private func updateIsSolved() {
        isSolved = true
        // 7. The wall can't form 2*2 squares.
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                if NurikabeGame.offset2.testAll({os in
                    let o = self[p + os]
                    if case .wall = o {return true} else {return false}
                }) {isSolved = false}
            }
        }
        let g = Graph()
        var pos2node = [Position: Node]()
        var rngWalls = [Position]()
        var rngEmpty = [Position]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                pos2node[p] = g.addNode(p.description)
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
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
                }
            }
        }
        for p in rngEmpty {
            for os in NurikabeGame.offset {
                let p2 = p + os
                if rngEmpty.contains(p2) {
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
                }
            }
        }
        if rngWalls.isEmpty {
            isSolved = false
        } else {
            // 3. The garden is separated by a single continuous wall. This means all
            // wall tiles on the board must be connected horizontally or vertically.
            // There can't be isolated walls.
            let nodesExplored = breadthFirstSearch(g, source: pos2node[rngWalls.first!]!)
            if rngWalls.count != nodesExplored.count {isSolved = false}
        }
        while !rngEmpty.isEmpty {
            let node = pos2node[rngEmpty.first!]!
            let nodesExplored = breadthFirstSearch(g, source: node)
            rngEmpty = rngEmpty.filter{!nodesExplored.contains($0.description)}
            let n2 = nodesExplored.count
            var rng = [Position]()
            for p in game.pos2hint.keys {
                if nodesExplored.contains(p.description) {
                    rng.append(p)
                }
            }
            switch rng.count {
            case 0:
                // 5. All the gardens in the puzzle are numbered at the start, there are no
                // hidden gardens.
                isSolved = false
            case 1:
                // 1. Each number on the grid indicates a garden, occupying as many tiles
                // as the number itself.
                let p = rng[0]
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
