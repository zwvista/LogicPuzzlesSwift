//
//  BanquetGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BanquetGameState: GridGameState<BanquetGameMove> {
    var game: BanquetGame {
        get { getGame() as! BanquetGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { BanquetDocument.sharedInstance }
    var hint2table = [Position: Position]()
    var table2hint = [Position: Position]()
    var tablePath = Set<Position>()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> BanquetGameState {
        let v = BanquetGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: BanquetGameState) -> BanquetGameState {
        _ = super.setup(v: v)
        v.hint2table = hint2table
        v.table2hint = table2hint
        v.tablePath = tablePath
        return v
    }
    
    required init(game: BanquetGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        for p in game.pos2hint.keys {
            hint2table[p] = p
            table2hint[p] = p
        }
        updateIsSolved()
    }
    
    override func setObject(move: inout BanquetGameMove) -> GameOperationType {
        let p = move.p
        guard let pHint = table2hint[p] else { return .invalid }
        table2hint.removeValue(forKey: p)
        if p != pHint {
            hint2table[pHint] = pHint
            table2hint[pHint] = pHint
        } else {
            // 2. The number on the table tells you how many tiles it must be moved.
            //    Tables without numbers must stay put.
            let os = BanquetGame.offset[move.dir]
            let n = game.pos2hint[p]!
            var pTable = p
            for i in 0..<n {
                pTable += os
                // 3. Tables can't cross other tables, nor cross other tables paths after
                //    they moved.
                guard isValid(p: pTable) && table2hint[pTable] == nil && !tablePath.contains(pTable) else { return .invalid }
            }
            pTable = p
            for i in 0..<n {
                pTable += os
                if i < n - 1 { tablePath.insert(pTable) }
            }
            hint2table[pHint] = pTable
            table2hint[pTable] = pHint
        }
        updateIsSolved()
        return .moveComplete
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 2/Banquet

        Summary
        A table here, please

        Description
        1. Join the tables in order to form "banquets" of at least two tables.
        2. The number on the table tells you how many tiles it must be moved.
           Tables without numbers must stay put.
        3. Tables can't cross other tables, nor cross other tables paths after
           they moved.
        4. Banquets cannot touch each other horizontally or vertically
           (they can touch diagonally).
        5. Banquets can't be L-shaped but can be more than one table wide.
    */
    private func updateIsSolved() {
        isSolved = true
        var tables = Set<Position>()
        for (pTable, pHint) in table2hint {
            if pTable == pHint {
                isSolved = false
            } else {
                tables.insert(pTable)
            }
        }
        // 1. Join the tables in order to form "banquets" of at least two tables.
        // 4. Banquets cannot touch each other horizontally or vertically
        //    (they can touch diagonally).
        // 5. Banquets can't be L-shaped but can be more than one table wide.
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard tables.contains(p) else {continue}
                pos2node[p] = g.addNode(p.description)
            }
        }
        for p in game.fixedTables {
            pos2node[p] = g.addNode(p.description)
        }
        for (p, node) in pos2node {
            for os in BanquetGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] { g.addEdge(node, neighbor: node2) }
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let banquet = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let n1 = banquet.count
            var r2 = 0, r1 = rows, c2 = 0, c1 = cols
            for p in banquet {
                if r2 < p.row { r2 = p.row }
                if r1 > p.row { r1 = p.row }
                if c2 < p.col { c2 = p.col }
                if c1 > p.col { c1 = p.col }
            }
            let rs = r2 - r1 + 1, cs = c2 - c1 + 1
            let s: AllowedObjectState = rs * cs == n1 && n1 > 1 ? .normal : .error
            if s != .normal { isSolved = false }
            for p in banquet { pos2state[p] = s }
        }
    }
}
