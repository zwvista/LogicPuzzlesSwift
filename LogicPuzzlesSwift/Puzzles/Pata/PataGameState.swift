//
//  PataGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PataGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: PataGame {
        get { getGame() as! PataGame }
        set { setGame(game: newValue) }
    }
    var gameDocument: PataDocument { PataDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { PataDocument.sharedInstance }
    var objArray = [PataObject]()
    
    override func copy() -> PataGameState {
        let v = PataGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: PataGameState) -> PataGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: PataGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<PataObject>(repeating: PataObject(), count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> PataObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> PataObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    func setObject(move: inout PataGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 { return false }
        guard String(describing: o1) != String(describing: o2) else { return false }
        self[p] = o2
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout PataGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: PataObject) -> PataObject {
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
        iOS Game: Logic Games/Puzzle Set 9/Pata

        Summary
        Yes, it's the opposite of Tapa

        Description
        1. Plays the opposite of Tapa, regarding the hints:
        2. A number indicates the groups of connected empty tiles that are around
           it, instead of filled ones.
        3. Different groups of empty tiles are separated by at least one filled cell.
        4. Same as Tapa:
        5. The filled tiles are continuous.
        6. You can't have a 2*2 space of filled tiles.
    */
    private func updateIsSolved() {
        isSolved = true
        // 2. A number indicates the groups of connected empty tiles that are around
        // it, instead of filled ones.
        func computeHint(emptied: [Int]) -> [Int] {
            if emptied.isEmpty { return [0] }
            var hint = [Int]()
            for j in 0..<emptied.count {
                if j == 0 || emptied[j] - emptied[j - 1] != 1 {
                    hint.append(1)
                } else {
                    hint[hint.count - 1] += 1
                }
            }
            if emptied.count > 1 && emptied.count > 1 && emptied.last! - emptied.first! == 7 {
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
            let emptied = [Int](0..<8).filter {
                let p2 = p + PataGame.offset[$0]
                guard isValid(p: p2) else { return false }
                switch self[p2] {
                case .empty, .hint: return true
                default: return false
                }
            }
            let arr = computeHint(emptied: emptied)
            let filled = [Int](0..<8).filter {
                let p2 = p + PataGame.offset[$0]
                if isValid(p: p2), case .wall = self[p2] { return true } else { return false }
            }
            let arr3 = computeHint(emptied: filled)
            let s: HintState = arr3 == [0] ? .normal : isCompatible(computedHint: arr, givenHint: arr2) ? .complete : .error
            self[p] = .hint(state: s)
            if s != .complete { isSolved = false }
        }
        guard isSolved else {return}
        // 6. You can't have a 2*2 space of filled tiles.
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                if PataGame.offset2.testAll({os in
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
            for os in PataGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        // 5. The filled tiles are continuous.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false; return }
    }
}
