//
//  TapAlikeGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TapAlikeGameState: GridGameState<TapAlikeGameMove> {
    var game: TapAlikeGame {
        get { getGame() as! TapAlikeGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TapAlikeDocument.sharedInstance }
    var objArray = [TapAlikeObject]()
    
    override func copy() -> TapAlikeGameState {
        let v = TapAlikeGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TapAlikeGameState) -> TapAlikeGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TapAlikeGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<TapAlikeObject>(repeating: TapAlikeObject(), count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> TapAlikeObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TapAlikeObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout TapAlikeGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 { return false }
        guard String(describing: o1) != String(describing: o2) else { return false }
        self[p] = o2
        updateIsSolved()
        return true
    }
    
    override func switchObject(move: inout TapAlikeGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: TapAlikeObject) -> TapAlikeObject {
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
        iOS Game: Logic Games/Puzzle Set 10/Tap-Alike

        Summary
        Dr. Jekyll and Mr. Tapa

        Description
        1. Plays with the same rules as Tapa with these variations:
        2. At the end of the solution, the filled tiles will form an identical
           pattern to the one formed by the empty tiles.
        3. It's basically like having the same figure rotated or reversed in the
           opposite colour. The two figures will have the same exact shape.
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
                let p2 = p + TapAlikeGame.offset[$0]
                return isValid(p: p2) && String(describing: self[p2]) == String(describing: TapAlikeObject.wall)
            }
            let arr = computeHint(filled: filled)
            let s: HintState = arr == [0] ? .normal : isCompatible(computedHint: arr, givenHint: arr2) ? .complete : .error
            self[p] = .hint(state: s)
            if s != .complete { isSolved = false }
        }
        guard isSolved else {return}
        // Filled tiles can't cover an area of 2*2 or larger (just like Nurikabe).
        // Tiles with numbers can be considered 'empty'.
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                if TapAlikeGame.offset2.testAll({os in
                    let o = self[p + os]
                    if case .wall = o { return true } else { return false }
                }) { isSolved = false; return }
            }
        }
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                if case .wall = self[p] { pos2node[p] = g.addNode(p.description) }
            }
        }
        for (p, node) in pos2node {
            for os in TapAlikeGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        // The goal is to fill some tiles forming a single orthogonally continuous
        // path. Just like Nurikabe.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false; return }
        // 2. At the end of the solution, the filled tiles will form an identical
        // pattern to the one formed by the empty tiles.
        // 3. It's basically like having the same figure rotated or reversed in the
        // opposite colour. The two figures will have the same exact shape.
        for r in 0..<rows {
            for c in 0..<cols {
                let (o1, o2) = (self[r, c], self[rows - 1 - r, cols - 1 - c])
                if (String(describing: o1) == String(describing: TapAlikeObject.wall)) == (String(describing: o2) == String(describing: TapAlikeObject.wall)) {
                    isSolved = false; return
                }
            }
        }
    }
}
