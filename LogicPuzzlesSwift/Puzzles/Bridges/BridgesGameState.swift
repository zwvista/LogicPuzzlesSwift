//
//  BridgesGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BridgesGameState: GridGameState<BridgesGameMove> {
    var game: BridgesGame {
        get { getGame() as! BridgesGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { BridgesDocument.sharedInstance }
    var objArray = [BridgesObject]()
    
    override func copy() -> BridgesGameState {
        let v = BridgesGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: BridgesGameState) -> BridgesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }

    required init(game: BridgesGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<BridgesObject>(repeating: BridgesObject(), count: rows * cols)
        for p in game.islandsInfo.keys {
            self[p] = .island(state: .normal, bridges: [0, 0, 0, 0])
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> BridgesObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> BridgesObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    func switchBridges(move: BridgesGameMove) -> Bool {
        let pFrom = move.pFrom, pTo = move.pTo
        // 4. Bridges can only run horizontally or vertically.
        guard pFrom < pTo,
            pFrom.row == pTo.row || pFrom.col == pTo.col,
            case .island(let state1, var bridges1) = self[pFrom],
            case .island(let state2, var bridges2) = self[pTo] else { return false }
        let n1 = pFrom.row == pTo.row ? 1 : 2
        let n2 = (n1 + 2) % 4
        let os = BridgesGame.offset[n1]
        var p = pFrom + os
        while p != pTo {
            switch bridges1[n1] {
            case 0:
                // 4. Bridges can't cross each other.
                guard case .empty = self[p] else { return false }
                self[p] = .bridge
            case 2:
                self[p] = .empty
            default:
                break
            }
            p += os
        }
        // 5. Lastly, you can connect two islands with either one or two Bridges
        // (or none, of course)
        let n = (bridges1[n1] + 1) % 3
        bridges1[n1] = n; bridges2[n2] = n
        self[pFrom] = .island(state: state1, bridges: bridges1)
        self[pTo] = .island(state: state2, bridges: bridges2)
        updateIsSolved()
        return true
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 7/Bridges

        Summary
        Enough Sudoku, let's build!

        Description
        1. The board represents a Sea with some islands on it.
        2. You must connect all the islands with Bridges, making sure every
           island is connected to each other with a Bridges path.
        3. The number on each island tells you how many Bridges are touching
           that island.
        4. Bridges can only run horizontally or vertically and can't cross
           each other.
        5. Lastly, you can connect two islands with either one or two Bridges
           (or none, of course)
    */
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        // 3. The number on each island tells you how many Bridges are touching
        // that island.
        for (p, info) in game.islandsInfo {
            guard case .island(var state, let bridges) = self[p] else {continue}
            let n1 = bridges.reduce(0, +)
            let n2 = info.bridges
            state = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 { isSolved = false }
            self[p] = .island(state: state, bridges: bridges)
            pos2node[p] = g.addNode(p.description)
        }
        guard isSolved else {return}
        for (p, info) in game.islandsInfo {
            guard case .island(_, let bridges) = self[p] else {continue}
            for i in 0..<4  {
                // if the neighbor is not nil
                guard let p2 = info.neighbors[i], bridges[i] > 0 else {continue}
                g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
            }
        }
        // 2. You must connect all the islands with Bridges, making sure every
        // island is connected to each other with a Bridges path.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
