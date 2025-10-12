//
//  TapaIslandsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TapaIslandsGameState: GridGameState<TapaIslandsGameMove> {
    var game: TapaIslandsGame {
        get { getGame() as! TapaIslandsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TapaIslandsDocument.sharedInstance }
    var objArray = [TapaIslandsObject]()
    
    override func copy() -> TapaIslandsGameState {
        let v = TapaIslandsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TapaIslandsGameState) -> TapaIslandsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TapaIslandsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<TapaIslandsObject>(repeating: TapaIslandsObject(), count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> TapaIslandsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TapaIslandsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout TapaIslandsGameMove) -> GameChangeType {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 { return false }
        guard String(describing: o1) != String(describing: o2) else { return false }
        self[p] = o2
        updateIsSolved()
        return .level
    }
    
    override func switchObject(move: inout TapaIslandsGameMove) -> GameChangeType {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: TapaIslandsObject) -> TapaIslandsObject {
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
        iOS Game: Logic Games/Puzzle Set 9/Tapa Islands

        Summary
        Tap-Archipelago

        Description
        1. Plays with the same rules as Tapa with these variations.
        2. Empty tiles from 'islands', or separated areas, are surrounded by the
           filled tiles.
        3. Each separated area may contain at most one clue tile.
        4. If there is a clue tile in an area, at least one digit should give the
           size of that area in unit squares.
    */
    private func updateIsSolved() {
        isSolved = true
        // A number indicates how many of the surrounding tiles are filled. If a
        // tile has more than one number, it hints at multiple separated groups
        // of filled tiles.
        func computeHint(filled: [Int]) -> [Int] {
            if filled.isEmpty { return [0] }
            var hint = [Int]()
            for j in 0..<filled.count {
                if j == 0 || filled[j] - filled[j - 1] != 1 {
                    hint.append(1)
                } else {
                    hint[hint.count - 1] += 1
                }
            }
            if filled.count > 1 && hint.count > 1 && filled.last! - filled.first! == 7 {
                hint[0] += hint.last!; hint.removeLast()
            }
            return hint.sorted()
        }
        func isCompatible(computedHint: [Int], givenHint: [Int]) -> Bool {
            if computedHint == givenHint { return true }
            if computedHint.count != givenHint.count { return false }
            let h1 = Set(computedHint)
            var h2 = Set(givenHint)
            h2.remove(-1)
            return h2.isSubset(of: h1)
        }
        for (p, arr2) in game.pos2hint {
            let filled = [Int](0..<8).filter {
                let p2 = p + TapaIslandsGame.offset[$0]
                return isValid(p: p2) && String(describing: self[p2]) == String(describing: TapaIslandsObject.wall)
            }
            let arr = computeHint(filled: filled)
            let s: HintState = arr == [0] ? .normal : isCompatible(computedHint: arr, givenHint: arr2) ? .complete : .error
            self[p] = .hint(state: s)
            if s != .complete { isSolved = false }
        }
        // Filled tiles can't cover an area of 2*2 or larger (just like Nurikabe).
        // Tiles with numbers can be considered 'empty'.
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                if TapaIslandsGame.offset2.testAll({os in
                    let o = self[p + os]
                    if case .wall = o { return true } else { return false }
                }) { isSolved = false }
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
            for os in TapaIslandsGame.offset {
                let p2 = p + os
                if rngWalls.contains(p2) {
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
                }
            }
        }
        for p in rngEmpty {
            for os in TapaIslandsGame.offset {
                let p2 = p + os
                if rngEmpty.contains(p2) {
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
                }
            }
        }
        guard !rngWalls.isEmpty else { isSolved = false; return }
        // The goal is to fill some tiles forming a single orthogonally continuous
        // path. Just like Nurikabe.
        let nodesExplored = breadthFirstSearch(g, source: pos2node[rngWalls.first!]!)
        if rngWalls.count != nodesExplored.count { isSolved = false }
        while !rngEmpty.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node[rngEmpty.first!]!)
            rngEmpty = rngEmpty.filter { !nodesExplored.contains($0.description) }
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
                // 3. Each separated area may contain at most one clue tile.
                // 4. If there is a clue tile in an area, at least one digit should give the
                // size of that area in unit squares.
                let p = rng[0]
                let arr2 = game.pos2hint[p]!
                let s: HintState = arr2.contains(n2) ? .complete : .error
                self[p] = .hint(state: s)
                if s != .complete { isSolved = false }
            default:
                for p in rng {
                    self[p] = .hint(state: .normal)
                }
                isSolved = false
            }
        }
    }
}
