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
    var hint2blanket = [Position: Position]()
    var blanket2hint = [Position: Position]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> BanquetGameState {
        let v = BanquetGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: BanquetGameState) -> BanquetGameState {
        _ = super.setup(v: v)
        v.hint2blanket = hint2blanket
        v.blanket2hint = blanket2hint
        return v
    }
    
    required init(game: BanquetGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        for p in game.pos2hint.keys {
            hint2blanket[p] = p
            blanket2hint[p] = p
        }
        updateIsSolved()
    }
    
    override func setObject(move: inout BanquetGameMove) -> GameOperationType {
        let p = move.p
        guard let pHint = blanket2hint[p] else { return .invalid }
        blanket2hint.removeValue(forKey: p)
        if p != pHint {
            hint2blanket[pHint] = pHint
            blanket2hint[pHint] = pHint
        } else {
            // 6. The number on top of the basket shows you how many tiles the basket must
            //    be flung.
            let os = BanquetGame.offset[move.dir]
            let n = game.pos2hint[p]!
            var pBlanket = p
            for _ in 0..<n {
                pBlanket += os
                guard isValid(p: pBlanket) else { return .invalid }
            }
            guard blanket2hint[pBlanket] == nil else { return .invalid }
            hint2blanket[pHint] = pBlanket
            blanket2hint[pBlanket] = pHint
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
        var blankets = Set<Position>()
        for (pBlanket, pHint) in blanket2hint {
            if pBlanket == pHint {
                isSolved = false
            } else {
                blankets.insert(pBlanket)
            }
        }
        // 4. find a way to lay every picnic basket so that no blanket touches another
        //    one, horizontally or vertically.
        for p in blankets {
            let s: AllowedObjectState = BanquetGame.offset.allSatisfy {
                !blankets.contains(p + $0)
            } ? .normal : .error
            pos2state[p] = s
            if s != .normal { isSolved = false }
        }
        guard isSolved else {return}
        // 5. Also the remaining park should be accessible to everyone, so empty grass
        //    spaces should form a single continuous area.
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard !blankets.contains(p) else {continue}
                pos2node[p] = g.addNode(p.description)
            }
        }
        for (p, node) in pos2node {
            for os in BanquetGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] { g.addEdge(node, neighbor: node2) }
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
