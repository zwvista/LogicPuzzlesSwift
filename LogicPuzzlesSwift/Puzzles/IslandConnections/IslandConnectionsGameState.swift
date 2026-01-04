//
//  IslandConnectionsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class IslandConnectionsGameState: GridGameState<IslandConnectionsGameMove> {
    var game: IslandConnectionsGame {
        get { getGame() as! IslandConnectionsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { IslandConnectionsDocument.sharedInstance }
    var objArray = [IslandConnectionsObject]()
    
    override func copy() -> IslandConnectionsGameState {
        let v = IslandConnectionsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: IslandConnectionsGameState) -> IslandConnectionsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }

    required init(game: IslandConnectionsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<IslandConnectionsObject>(repeating: IslandConnectionsObject(), count: rows * cols)
        for p in game.islandsInfo.keys {
            self[p] = .island(state: .normal, bridges: [0, 0, 0, 0])
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> IslandConnectionsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> IslandConnectionsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    func switchIslandConnections(move: IslandConnectionsGameMove) -> GameOperationType {
        let pFrom = move.pFrom, pTo = move.pTo
        // 4. IslandConnections can only run horizontally or vertically.
        guard pFrom < pTo,
            pFrom.row == pTo.row || pFrom.col == pTo.col,
            case .island(let state1, var bridges1) = self[pFrom],
            case .island(let state2, var bridges2) = self[pTo] else { return .invalid }
        let n1 = pFrom.row == pTo.row ? 1 : 2
        let n2 = (n1 + 2) % 4
        let os = IslandConnectionsGame.offset[n1]
        var p = pFrom + os
        while p != pTo {
            switch bridges1[n1] {
            case 0:
                // 4. IslandConnections can't cross each other.
                guard case .empty = self[p] else { return .invalid }
                self[p] = .bridge
            case 2:
                self[p] = .empty
            default:
                break
            }
            p += os
        }
        // 5. Lastly, you can connect two islands with either one or two IslandConnections
        // (or none, of course)
        let n = (bridges1[n1] + 1) % 3
        bridges1[n1] = n; bridges2[n2] = n
        self[pFrom] = .island(state: state1, bridges: bridges1)
        self[pTo] = .island(state: state2, bridges: bridges2)
        updateIsSolved()
        return .moveComplete
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 5/Island Connections

        Summary
        Simpler Bridges

        Description
        1. Connect the islands with bridges.
        2. All the islands must be connected between them, forming a single path.
        3. Bridges are horizontal or vertical straight lines and cannot cross each other.
        4. Islands with numbers tell you how many bridges depart from it.
        5. Islands without a number can have any number of bridges.
        6. Shaded islands cannot be connected and should be avoided.
    */
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        // 3. The number on each island tells you how many IslandConnections are touching
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
        // 2. You must connect all the islands with IslandConnections, making sure every
        // island is connected to each other with a IslandConnections path.
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
