//
//  InbetweenNurikabeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class InbetweenNurikabeGameState: GridGameState<InbetweenNurikabeGameMove> {
    var game: InbetweenNurikabeGame {
        get { getGame() as! InbetweenNurikabeGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { InbetweenNurikabeDocument.sharedInstance }
    var objArray = [InbetweenNurikabeObject]()
    var pos2state = [Position: HintState]()
    var invalid2x2Squares = [Position]()

    override func copy() -> InbetweenNurikabeGameState {
        let v = InbetweenNurikabeGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: InbetweenNurikabeGameState) -> InbetweenNurikabeGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: InbetweenNurikabeGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<InbetweenNurikabeObject>(repeating: InbetweenNurikabeObject(), count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> InbetweenNurikabeObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> InbetweenNurikabeObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout InbetweenNurikabeGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), self[p] != .hint, self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout InbetweenNurikabeGameMove) -> GameOperationType {
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
        iOS Game: 100 Logic Games 3/Puzzle Set 4/Inbetween Nurikabe

        Summary
        The garden between

        Description
        1. Create a Nurikabe, where each Garden has two numbers.
        2. The area of the garden must be between the two numbers.
        3. For example 2 and 4 give you an area of 3 tiles. 1 and 5 give you
           an area that can be 2, 3 or 4 tiles big.
    */
    private func updateIsSolved() {
        isSolved = true
        // 7. The wall can't form 2*2 squares.
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                let rng = InbetweenNurikabeGame.offset2.map { p + $0 }.filter { self[$0] == .wall }
                if rng.count == 4 {
                    isSolved = false
                    invalid2x2Squares.append(p + Position.SouthEast)
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
            for os in InbetweenNurikabeGame.offset {
                let p2 = p + os
                if rngWalls.contains(p2) {
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
                }
            }
        }
        for p in rngEmpty {
            for os in InbetweenNurikabeGame.offset {
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
            if rng.count == 2 {
                // 2. The area of the garden must be between the two numbers.
                let nums = rng.map { game.pos2hint[$0]! }.sorted()
                let s: HintState = nums[0] < n2 && n2 < nums[1] ? .complete : .error
                for p in rng { pos2state[p] = s }
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
