//
//  TapaGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TapaGameState: GridGameState<TapaGameMove> {
    var game: TapaGame {
        get { getGame() as! TapaGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { TapaDocument.sharedInstance }
    var objArray = [TapaObject]()
    
    override func copy() -> TapaGameState {
        let v = TapaGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TapaGameState) -> TapaGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TapaGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<TapaObject>(repeating: TapaObject(), count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> TapaObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> TapaObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout TapaGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 { return false }
        guard String(describing: o1) != String(describing: o2) else { return false }
        self[p] = o2
        updateIsSolved()
        return true
    }
    
    override func switchObject(move: inout TapaGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: TapaObject) -> TapaObject {
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
        iOS Game: Logic Games/Puzzle Set 9/Tapa

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
        5. Tapa has plenty of variations. Some are available in the levels of this
           game. Stronger variations are B-W Tapa, Island Tapa and Pata and have
           their own game.
        6. Equal Tapa - The board contains an equal number of white and black tiles.
           Tiles with numbers or question marks are NOT counted as empty or filled
           for this rule (i.e. they're left out of the count).
        7. Four-Me-Tapa - Four-Me-Not rule apply: you can't have more than three
           filled tiles in line.
        8. No Square Tapa - No 2*2 area of the board can be left empty.
    */
    private func updateIsSolved() {
        isSolved = true
        // 2. A number indicates how many of the surrounding tiles are filled. If a
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
                let p2 = p + TapaGame.offset[$0]
                return isValid(p: p2) && String(describing: self[p2]) == String(describing: TapaObject.wall)
            }
            let arr = computeHint(filled: filled)
            let s: HintState = arr == [0] ? .normal : isCompatible(computedHint: arr, givenHint: arr2) ? .complete : .error
            self[p] = .hint(state: s)
            if s != .complete { isSolved = false }
        }
        guard isSolved else {return}
        // 4. Filled tiles can't cover an area of 2*2 or larger (just like Nurikabe).
        // Tiles with numbers can be considered 'empty'.
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                if TapaGame.offset2.testAll({os in
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
            for os in TapaGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        // 1. The goal is to fill some tiles forming a single orthogonally continuous
        // path. Just like Nurikabe.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
