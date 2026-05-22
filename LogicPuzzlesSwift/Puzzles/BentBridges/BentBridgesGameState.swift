//
//  BentBridgesGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BentBridgesGameState: GridGameState<BentBridgesGameMove> {
    var game: BentBridgesGame {
        get { getGame() as! BentBridgesGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { BentBridgesDocument.sharedInstance }
    var objArray = [BentBridgesObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> BentBridgesGameState {
        let v = BentBridgesGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: BentBridgesGameState) -> BentBridgesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }

    required init(game: BentBridgesGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<BentBridgesObject>(repeating: BentBridgesObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> BentBridgesObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> BentBridgesObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout BentBridgesGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + BentBridgesGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }

    /*
        iOS Game: 100 Logic Games 3/Puzzle Set 1/Bent Bridges

        Summary
        One turn at most

        Description
        1. Connect all the islands together with bridges.
        2. You should be able to go from any island to any other island in the end.
        3. The number on the island tells you how many bridges connect to that island.
        4. A bridge can turn once by 90 degrees between islands.
        5. Bridges cannot cross each other.

        Variants
        6. Crossing: bridges can cross each other, but cannot turn at the intersection.
        7. Magnetic: islands with the same number cannot have a bridge between themselves.
    */
    private func updateIsSolved() {
        isSolved = true
        var islands = Set<Position>()
        var pos2dirs = [Position: [Int]]()
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let dirs = (0..<4).filter { self[p][$0] }
                let cnt = dirs.count
                if game.pos2hint[p] == nil {
                    if cnt == 2 {
                        // 1. Connect all the islands together with bridges.
                        pos2dirs[p] = dirs
                    } else if !dirs.isEmpty {
                        isSolved = false
                    }
                } else {
                    pos2state[p] = .normal
                    pos2node[p] = g.addNode(p.description)
                    if !dirs.isEmpty {
                        islands.insert(p)
                        pos2dirs[p] = dirs
                    } else {
                        // 1. Connect all the islands together with bridges.
                        isSolved = false
                    }
                }
            }
        }
        // 3. The number on the island tells you how many bridges connect to that island.
        while !islands.isEmpty {
            let p = islands.first!
            let n2 = game.pos2hint[p]!
            var n1 = 0
            let dirs = pos2dirs[p]!
            for d in dirs {
                var i = d
                var os = BentBridgesGame.offset[i]
                var p2 = p + os
                var turns = 0
                while true {
                    let j = (i + 2) % 4
                    guard game.pos2hint[p2] == nil else {break}
                    guard var dirs = pos2dirs[p2] else {break}
                    dirs = dirs.filter { $0 != j }
                    guard !dirs.isEmpty else {break}
                    let k = dirs.first!
                    if k != i {
                        turns += 1
                        i = k
                    }
                    os = BentBridgesGame.offset[i]
                    p2 += os
                }
                let n3 = game.pos2hint[p2]
                // 4. A bridge can turn once by 90 degrees between islands.
                if n3 != nil && turns < 2 {
                    n1 += 1
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
                } else {
                    isSolved = false
                }
            }
            islands.remove(p)
            let s: HintState = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            pos2state[p] = s
            if s != .complete { isSolved = false }
        }
        guard isSolved else {return}
        // 1. Connect all the islands together with bridges.
        // 2. You should be able to go from any island to any other island in the end.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
