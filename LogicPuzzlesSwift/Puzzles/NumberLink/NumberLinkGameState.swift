//
//  NumberLinkGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class NumberLinkGameState: GridGameState<NumberLinkGameMove> {
    var game: NumberLinkGame {
        get { getGame() as! NumberLinkGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { NumberLinkDocument.sharedInstance }
    var objArray = [NumberLinkObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> NumberLinkGameState {
        let v = NumberLinkGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: NumberLinkGameState) -> NumberLinkGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: NumberLinkGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<NumberLinkObject>(repeating: NumberLinkObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> NumberLinkObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> NumberLinkObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout NumberLinkGameMove) -> Bool {
        let p = move.p, dir = move.dir
        let p2 = p + NumberLinkGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return false }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return true
    }
    
    
    /*
        iOS Game: Logic Games/Puzzle Set 3/NumberLink

        Summary
        Connect the same numbers without the crossing paths

        Description
        1. Connect the couples of equal numbers (i.e. 2 with 2, 3 with 3 etc)
           with a continuous line.
        2. The line can only go horizontally or vertically and can't cross
           itself or other lines.
        3. Lines must originate on a number and must end in the other equal
           number.
        4. At the end of the puzzle, you must have covered ALL the squares with
           lines and no line can cover a 2*2 area (like a 180 degree turn).
        5. In other words you can't turn right and immediately right again. The
           same happens on the left, obviously. Be careful not to miss this rule.

        Variant
        6. In some levels there will be a note that tells you don't need to cover
           all the squares.
        7. In some levels you will have more than a couple of the same number.
           In these cases, you must connect ALL the same numbers together.
    */
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        var pos2indexes = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let n = self[p].filter { $0 }.count
                let b = game.pos2hint[p] != nil
                pos2node[p] = g.addNode(p.description)
                if b && n == 1 || !b && n == 2 {
                    pos2indexes[p] = (0..<4).filter { self[p][$0] }
                } else {
                    // 3. Lines must originate on a number and must end in the other equal
                    // number.
                    isSolved = false
                }
            }
        }
        for (p, node) in pos2node {
            pos2state[p] = .normal
            guard let indexes = pos2indexes[p] else {continue}
            for i in indexes {
                let p2 = p + NumberLinkGame.offset[i]
                let node2 = pos2node[p2]!
                g.addEdge(node, neighbor: node2)
            }
            guard indexes.count == 2 else {continue}
            let (i1, i2) = (indexes[0], indexes[1])
            // 4. At the end of the puzzle, no line can cover a 2*2 area (like a 180 degree turn).
            // 5. In other words you can't turn right and immediately right again. The
            // same happens on the left, obviously. Be careful not to miss this rule.
            func f(i: Int, isRight: Bool) {
                let p2 = p + NumberLinkGame.offset[i]
                guard var indexes2 = pos2indexes[p2], indexes2.count == 2 else {return}
                let i3 = (i + 2) % 4
                indexes2.removeFirst(i1)
                let i4 = indexes2[0]
                if isRight && (i3 + 3) % 4 == i4 || !isRight && (i3 + 1) % 4 == i4 { pos2state[p] = .error; isSolved = false }
            }
            if (i1 + 3) % 4 == i2 { f(i: i2, isRight: true) }
            if (i2 + 3) % 4 == i1 { f(i: i1, isRight: true) }
            if (i1 + 1) % 4 == i2 { f(i: i2, isRight: false) }
            if (i2 + 1) % 4 == i1 { f(i: i1, isRight: false) }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.0.description) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.0.description) }
            let rng1 = area.filter { game.pos2hint[$0] != nil }
            guard !rng1.isEmpty else { isSolved = false; continue }
            let rng2 = game.hint2rng[game.pos2hint[rng1[0]]!]!
            let (b1, b2, b3) = (rng1.difference(rng2).isEmpty, rng2.difference(rng1).isEmpty, area.testAll { self.pos2state[$0] != .error })
            // 3. Lines must originate on a number and must end in the other equal
            // number.
            // 4. At the end of the puzzle, you must have covered ALL the squares with
            // lines.
            let s: HintState = !b1 || !b3 ? .error : b2 ? .complete : .normal
            if s != .complete { isSolved = false }
            for p in rng1 {
                pos2state[p] = s
            }
        }
    }
}
