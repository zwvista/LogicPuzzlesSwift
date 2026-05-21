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
        let p2 = p + CaffelatteGame.offset[dir], dir2 = (dir + 2) % 4
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
//        let g = Graph()
//        var pos2node = [Position: Node]()
//        // 3. The number on each island tells you how many BentBridges are touching
//        // that island.
//        for (p, info) in game.islandsInfo {
//            guard case .island(var state, let bridges) = self[p] else {continue}
//            let n1 = bridges.reduce(0, +)
//            let n2 = info.bridges
//            state = n1 < n2 ? .normal : n1 == n2 ? .complete : .error
//            if state != .complete { isSolved = false }
//            self[p] = .island(state: state, bridges: bridges)
//            pos2node[p] = g.addNode(p.description)
//        }
//        guard isSolved else {return}
//        for (p, info) in game.islandsInfo {
//            guard case .island(_, let bridges) = self[p] else {continue}
//            for i in 0..<4  {
//                // if the neighbor is not nil
//                guard let p2 = info.neighbors[i], bridges[i] > 0 else {continue}
//                g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
//            }
//        }
//        // 2. You must connect all the islands with BentBridges, making sure every
//        // island is connected to each other with a BentBridges path.
//        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
//        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
