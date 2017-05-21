//
//  BWTapaGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BWTapaGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: BWTapaGame {
        get {return getGame() as! BWTapaGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: BWTapaDocument { return BWTapaDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return BWTapaDocument.sharedInstance }
    var objArray = [BWTapaObject]()
    
    override func copy() -> BWTapaGameState {
        let v = BWTapaGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: BWTapaGameState) -> BWTapaGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: BWTapaGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<BWTapaObject>(repeating: BWTapaObject(), count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> BWTapaObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> BWTapaObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout BWTapaGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 {return false}
        guard String(describing: o1) != String(describing: o2) else {return false}
        self[p] = o2
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout BWTapaGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: BWTapaObject) -> BWTapaObject {
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
        iOS Game: Logic Games/Puzzle Set 9/BWTapa

        Summary
        Turkish art of PAint(TAPA)

        Description
        1. The goal is to fill some tiles forming a single orthogonally continuous
           path. Just like Nurikabe.
        2. A number indicates how many of the surrounding tiles are filled. If a
           tile has more than one number, it hints at multiple separated groups
           of filled tiles.
        3. For example, a cell with a 1 and 3 means there is a continuous group
           of 3 filled cells around it and one more single filled cell, separated
           from the other 3. The order of the numbers in this case is irrelevant.
        4. Filled tiles can't cover an area of 2*2 or larger (just like Nurikabe).
           Tiles with numbers can be considered 'empty'.

        Variations
        5. BWTapa has plenty of variations. Some are available in the levels of this
           game. Stronger variations are B-W BWTapa, Island BWTapa and Pata and have
           their own game.
        6. Equal BWTapa - The board contains an equal number of white and black tiles.
           Tiles with numbers or question marks are NOT counted as empty or filled
           for this rule (i.e. they're left out of the count).
        7. Four-Me-BWTapa - Four-Me-Not rule apply: you can't have more than three
           filled tiles in line.
        8. No Square BWTapa - No 2*2 area of the board can be left empty.
    */
    private func updateIsSolved() {
        isSolved = true
        func computeHint(filled: [Int]) -> [Int] {
            if filled.isEmpty {return [0]}
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
            if computedHint == givenHint {return true}
            if computedHint.count != givenHint.count {return false}
            let h1 = Set(computedHint)
            var h2 = Set(givenHint)
            h2.remove(-1)
            return h2.isSubset(of: h1)
        }
        for (p, arr2) in game.pos2hint {
            let filled = [Int](0..<8).filter({
                let p2 = p + BWTapaGame.offset[$0]
                return isValid(p: p2) && String(describing: self[p2]) == String(describing: BWTapaObject.wall)
            })
            let arr = computeHint(filled: filled)
            let s: HintState = arr == [0] ? .normal : isCompatible(computedHint: arr, givenHint: arr2) ? .complete : .error
            self[p] = .hint(state: s)
            if s != .complete {isSolved = false}
        }
        guard isSolved else {return}
        for r in 0..<rows - 1 {
            rule2x2:
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                for os in BWTapaGame.offset2 {
                    guard case .wall = self[p + os] else {continue rule2x2}
                }
                isSolved = false; return
            }
        }
        let g = Graph()
        var pos2node = [Position: Node]()
        var rngWalls = [Position]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                pos2node[p] = g.addNode(p.description)
                switch self[p] {
                case .wall:
                    rngWalls.append(p)
                default:
                    break
                }
            }
        }
        for p in rngWalls {
            for os in BWTapaGame.offset {
                let p2 = p + os
                if rngWalls.contains(p2) {
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
                }
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node[rngWalls.first!]!)
        if rngWalls.count != nodesExplored.count {isSolved = false}
    }
}
