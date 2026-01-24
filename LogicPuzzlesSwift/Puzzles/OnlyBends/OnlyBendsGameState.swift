//
//  OnlyBendsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class OnlyBendsGameState: GridGameState<OnlyBendsGameMove> {
    var game: OnlyBendsGame {
        get { getGame() as! OnlyBendsGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { OnlyBendsDocument.sharedInstance }
    var objArray = [OnlyBendsObject]()
    
    override func copy() -> OnlyBendsGameState {
        let v = OnlyBendsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: OnlyBendsGameState) -> OnlyBendsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: OnlyBendsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<OnlyBendsObject>(repeating: OnlyBendsObject(repeating: false, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> OnlyBendsObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> OnlyBendsObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout OnlyBendsGameMove) -> GameOperationType {
        let p = move.p, dir = move.dir
        let p2 = p + OnlyBendsGame.offset[dir], dir2 = (dir + 2) % 4
        guard isValid(p: p2) else { return .invalid }
        self[p][dir].toggle()
        self[p2][dir2].toggle()
        updateIsSolved()
        return .moveComplete
    }
    
    
    /*
        iOS Game: 100 Logic Games 4/Puzzle Set 1/Only Bends

        Summary
        We don't like long straights

        Description
        1. Connect pairs of houses with roads that can't go straight! :)
        2. Each house must be connected with another house. The road connecting
           them can't have straights, but has to turn on every tile it passes through.
        3. Roads cannot cross and cannot go over other houses.
        4. The entire board must be filled with roads! (asphalt lobby rule)
    */
    private func updateIsSolved() {
        isSolved = true
        var rng = [Position]()
        var pos2dirs = [Position: [Int]]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                rng.append(p)
                let dirs = (0..<4).filter { self[p][$0] }
                pos2dirs[p] = dirs
                let cnt = dirs.count
                if game[p] == " " {
                    // 2. The road connecting
                    //    them can't have straights, but has to turn on every tile it passes through.
                    // 4. The entire board must be filled with roads! (asphalt lobby rule)
                    guard cnt == 2 && (dirs[0] + 2) % 4 != dirs[1] else { isSolved = false; return }
                } else {
                    // 3. Roads cannot cross and cannot go over other houses.
                    guard cnt == 1 else { isSolved = false; return }
                }
            }
        }
        // 2. Each house must be connected with another house.
        let g = Graph()
        var pos2node = [Position: Node]()
        for p in rng {
            pos2node[p] = g.addNode(p.description)
        }
        for p in rng {
            for i in 0..<4 {
                guard self[p][i] else {continue}
                guard let node2 = pos2node[p + OnlyBendsGame.offset[i]] else { isSolved = false; return }
                g.addEdge(pos2node[p]!, neighbor: node2)
            }
        }
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let area = pos2node.filter { nodesExplored.contains($0.1.label) }.map { $0.0 }
            pos2node = pos2node.filter { !nodesExplored.contains($0.1.label) }
            let nHouse = area.count { game[$0] != " " }
            guard nHouse == 2 else { isSolved = false; return }
        }
    }
}
