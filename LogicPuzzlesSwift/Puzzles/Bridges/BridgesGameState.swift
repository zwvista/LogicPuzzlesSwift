//
//  BridgesGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class BridgesGameState: GridGameState, BridgesMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: BridgesGame {
        get {return getGame() as! BridgesGame}
        set {setGame(game: newValue)}
    }
    var objArray = [BridgesObject]()
    
    override func copy() -> BridgesGameState {
        let v = BridgesGameState(game: game)
        return setup(v: v)
    }
    func setup(v: BridgesGameState) -> BridgesGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }

    required init(game: BridgesGame) {
        super.init(game: game)
        objArray = Array<BridgesObject>(repeating: BridgesObject(), count: rows * cols)
        for p in game.islandsInfo.keys {
            self[p] = .island(state: .normal, bridges: [0, 0, 0, 0])
        }
    }
    
    subscript(p: Position) -> BridgesObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> BridgesObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func switchBridges(move: BridgesGameMove) -> Bool {
        let pFrom = move.pFrom, pTo = move.pTo
        guard pFrom < pTo,
            pFrom.row == pTo.row || pFrom.col == pTo.col,
            case .island(let state1, var bridges1) = self[pFrom],
            case .island(let state2, var bridges2) = self[pTo] else {return false}
        let n1 = pFrom.row == pTo.row ? 1 : 2
        let n2 = (n1 + 2) % 4
        let os = BridgesGame.offset[n1]
        var p = pFrom + os
        while p != pTo {
            switch bridges1[n1] {
            case 0:
                guard case .empty = self[p] else {return false}
                self[p] = .bridge
            case 2:
                self[p] = .empty
            default:
                break
            }
            p += os
        }
        let n = (bridges1[n1] + 1) % 3
        bridges1[n1] = n; bridges2[n2] = n
        self[pFrom] = .island(state: state1, bridges: bridges1)
        self[pTo] = .island(state: state2, bridges: bridges2)
        updateIsSolved()
        return true
    }
    
    private func updateIsSolved() {
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        for (p, info) in game.islandsInfo {
            guard case .island(var state, let bridges) = self[p] else {continue}
            let n1 = bridges.reduce(0, +)
            let n2 = info.bridges
            state = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 {isSolved = false}
            self[p] = .island(state: state, bridges: bridges)
            pos2node[p] = g.addNode(p.description)
        }
        guard isSolved else {return}
        for (p, info) in game.islandsInfo {
            for p2 in info.neighbors {
                guard let p2 = p2 else {continue}
                g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.values.first!)
        let n1 = nodesExplored.count
        let n2 = pos2node.values.count
        if n1 != n2 {isSolved = false}
    }
}
