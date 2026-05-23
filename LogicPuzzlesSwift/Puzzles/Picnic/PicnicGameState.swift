//
//  PicnicGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class PicnicGameState: GridGameState<PicnicGameMove> {
    var game: PicnicGame {
        get { getGame() as! PicnicGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { PicnicDocument.sharedInstance }
    var hint2blanket = [Position: Position]()
    var blanket2hint = [Position: Position]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> PicnicGameState {
        let v = PicnicGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: PicnicGameState) -> PicnicGameState {
        _ = super.setup(v: v)
        v.hint2blanket = hint2blanket
        v.blanket2hint = blanket2hint
        return v
    }
    
    required init(game: PicnicGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        updateIsSolved()
    }
    
    override func setObject(move: inout PicnicGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        if let pHint = blanket2hint[p], dir == PicnicGame.PUZ_TAP_MOVE {
            blanket2hint.removeValue(forKey: p)
            hint2blanket.removeValue(forKey: pHint)
        } else if game.pos2hint[p] != nil, dir != PicnicGame.PUZ_TAP_MOVE {
            // 6. The number on top of the basket shows you how many tiles the basket must
            //    be flung.
            let os = PicnicGame.offset[dir]
            let n = game.pos2hint[p]!
            var pBlanket = p
            for _ in 0..<n {
                pBlanket += os
                guard isValid(p: pBlanket) else { return .invalid }
            }
            guard blanket2hint[pBlanket] == nil && (game.pos2hint[pBlanket] == nil || hint2blanket[pBlanket] != nil) else { return .invalid }
            hint2blanket[p] = pBlanket
            blanket2hint[pBlanket] = p
        } else { return .invalid }
        updateIsSolved()
        return .moveComplete
    }
    
    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 1/Picnic

        Summary
        Fling the Blanket

        Description
        1. As usual, on the day of the National Holiday Picnic, the park is crowded.
        2. You brought your picnic basket (like everyone else) and your blanket (like
           everyone else).
        3. The object is to make space for everyone and to leave the park open for
           walking around.
        4. find a way to lay every picnic basket so that no blanket touches another
           one, horizontally or vertically.
        5. Also the remaining park should be accessible to everyone, so empty grass
           spaces should form a single continuous area.
        6. The number on top of the basket shows you how many tiles the basket must
           be flung.
    */
    private func updateIsSolved() {
        isSolved = true
        if blanket2hint.count != game.pos2hint.count { isSolved = false }
        // 4. find a way to lay every picnic basket so that no blanket touches another
        //    one, horizontally or vertically.
        for p in blanket2hint.keys {
            let s: AllowedObjectState = PicnicGame.offset.allSatisfy {
                blanket2hint[p + $0] == nil
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
                guard blanket2hint[p] == nil else {continue}
                pos2node[p] = g.addNode(p.description)
            }
        }
        for (p, node) in pos2node {
            for os in PicnicGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] { g.addEdge(node, neighbor: node2) }
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
