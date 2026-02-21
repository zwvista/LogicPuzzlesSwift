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
        objArray = Array<BentBridgesObject>(repeating: BentBridgesObject(), count: rows * cols)
        for p in game.islandsInfo.keys {
            self[p] = .island(state: .normal, bridges: [0, 0, 0, 0])
        }
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
    
    func switchBentBridges(move: BentBridgesGameMove) -> GameOperationType {
        let pFrom = move.pFrom, pTo = move.pTo
        // 4. BentBridges can only run horizontally or vertically.
        guard pFrom < pTo,
            pFrom.row == pTo.row || pFrom.col == pTo.col,
            case .island(let state1, var bridges1) = self[pFrom],
            case .island(let state2, var bridges2) = self[pTo] else { return .invalid }
        let n1 = pFrom.row == pTo.row ? 1 : 2
        let n2 = (n1 + 2) % 4
        let os = BentBridgesGame.offset[n1]
        var p = pFrom + os
        while p != pTo {
            switch bridges1[n1] {
            case 0:
                // 4. BentBridges can't cross each other.
                guard case .empty = self[p] else { return .invalid }
                self[p] = .bridge
            case 2:
                self[p] = .empty
            default:
                break
            }
            p += os
        }
        // 5. Lastly, you can connect two islands with either one or two BentBridges
        // (or none, of course)
        let n = (bridges1[n1] + 1) % 3
        bridges1[n1] = n; bridges2[n2] = n
        self[pFrom] = .island(state: state1, bridges: bridges1)
        self[pTo] = .island(state: state2, bridges: bridges2)
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
        let g = Graph()
        var pos2node = [Position: Node]()
        // 3. The number on each island tells you how many BentBridges are touching
        // that island.
        for (p, info) in game.islandsInfo {
            guard case .island(var state, let bridges) = self[p] else {continue}
            let n1 = bridges.reduce(0, +)
            let n2 = info.bridges
            state = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if state != .complete { isSolved = false }
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
        // 2. You must connect all the islands with BentBridges, making sure every
        // island is connected to each other with a BentBridges path.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
