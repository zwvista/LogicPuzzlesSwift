//
//  NurikabeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NurikabeGameState: GridGameState<NurikabeGameMove> {
    var game: NurikabeGame {
        get { getGame() as! NurikabeGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { NurikabeDocument.sharedInstance }
    var objArray = [NurikabeObject]()
    var pos2state = [Position: HintState]()
    var invalid2x2Squares = [Position]()

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
            self[p] = .hint
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> NurikabeObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> NurikabeObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout NurikabeGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), self[p] != .hint, self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout NurikabeGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), self[p] != .hint else { return .invalid }
        let markerOption = MarkerOptions(rawValue: markerOption)
        let o = self[p]
        move.obj = switch o {
        case .empty: markerOption == .markerFirst ? .marker : .wall
        case .wall: markerOption == .markerLast ? .marker : .empty
        case .marker: markerOption == .markerFirst ? .wall : .empty
        case .hint: o
        }
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
                if NurikabeGame.offset2.map({ p + $0 }).allSatisfy({ self[$0] == .wall }) { invalid2x2Squares.append(p + Position.SouthEast); isSolved = false
                }
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
                if self[p] == .wall {
                    rngWalls.append(p)
                } else {
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
            //    wall tiles on the board must be connected horizontally or vertically.
            //    There can't be isolated walls.
            let nodesExplored = breadthFirstSearch(g, source: pos2node[rngWalls.first!]!)
            if rngWalls.count != nodesExplored.count { isSolved = false }
        }
        while !rngEmpty.isEmpty {
            let node = pos2node[rngEmpty.first!]!
            let nodesExplored = breadthFirstSearch(g, source: node)
            rngEmpty = rngEmpty.filter { !nodesExplored.contains($0.description) }
            let n2 = nodesExplored.count
            var rng = [Position]()
            for p in game.pos2hint.keys {
                if nodesExplored.contains(p.description) {
                    rng.append(p)
                }
            }
            if rng.count == 1 {
                // 1. Each number on the grid indicates a garden, occupying as many tiles
                //    as the number itself.
                let p = rng[0]
                let n1 = game.pos2hint[p]!
                let s: HintState = n1 == n2 ? .complete : .error
                pos2state[p] = s
                if s != .complete { isSolved = false }
            } else {
                // 5. All the gardens in the puzzle are numbered at the start, there are no
                //    hidden gardens.
                isSolved = false
                for p in rng { pos2state[p] = .normal }
            }
        }
    }
}
