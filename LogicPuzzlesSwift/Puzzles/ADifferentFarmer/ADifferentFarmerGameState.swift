//
//  ADifferentFarmerGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class ADifferentFarmerGameState: GridGameState<ADifferentFarmerGameMove> {
    var game: ADifferentFarmerGame {
        get { getGame() as! ADifferentFarmerGame }
        set { setGame(game: newValue) }
    }
    override var gameDocument: GameDocumentBase { ADifferentFarmerDocument.sharedInstance }
    var objArray = [ADifferentFarmerObject]()
    var pos2state = [Position: AllowedObjectState]()

    override func copy() -> ADifferentFarmerGameState {
        let v = ADifferentFarmerGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: ADifferentFarmerGameState) -> ADifferentFarmerGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: ADifferentFarmerGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = game.objArray
        updateIsSolved()
    }
    
    subscript(p: Position) -> ADifferentFarmerObject {
        get { self[p.row, p.col] }
        set { self[p.row, p.col] = newValue }
    }
    subscript(row: Int, col: Int) -> ADifferentFarmerObject {
        get { objArray[row * cols + col] }
        set { objArray[row * cols + col] = newValue }
    }
    
    override func setObject(move: inout ADifferentFarmerGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty, self[p] != move.obj else { return .invalid }
        self[p] = move.obj
        updateIsSolved()
        return .moveComplete
    }
    
    override func switchObject(move: inout ADifferentFarmerGameMove) -> GameOperationType {
        let p = move.p
        guard isValid(p: p), game[p] == .empty else { return .invalid }
        let o = self[p]
        move.obj = switch o {
        case .empty: .fv1
        case .fv1: .fv2
        case .fv2: .fv3
        case .fv3: .empty
        }
        return setObject(move: &move)
    }
    
    /*
        iOS Game: 100 Logic Games 2/Puzzle Set 4/A different Farmer

        Summary
        Not all farmers are created equal

        Description
        1. A Different Farmer plants fruits and vegetables in a different way.
        2. He places exactly one of each of the three fruits or vegetables in each field
           (marked area).
        3. The same plant cannot be placed in adjacent tiles, not even diagonally.
        4. All the plants must be connected horizontally or vertically.
    */
    private func updateIsSolved() {
        isSolved = true
        for r in 0..<rows {
            for c in 0..<cols {
                pos2state[Position(r, c)] = .normal
            }
        }
        // 2. He places exactly one of each of the three fruits or vegetables in each field
        //    (marked area).
        for area in game.areas {
            var symbol2range = [ADifferentFarmerObject: [Position]]()
            for p in area {
                let o = self[p]
                if o == .empty {continue}
                symbol2range[o, default: []].append(p)
            }
            if symbol2range.count != 3 { isSolved = false }
            for (o, range) in symbol2range where range.count > 1 {
                isSolved = false
                for p in range { pos2state[p] = .error }
            }
        }
        // 3. The same plant cannot be placed in adjacent tiles, not even diagonally.
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                let o = self[p]
                guard o != .empty else {continue}
                for os in ADifferentFarmerGame.offset3 {
                    let p2 = p + os
                    guard isValid(p: p2) else {continue}
                    if self[p2] == o {
                        isSolved = false
                        pos2state[p] = .error
                    }
                }
            }
        }
        guard isSolved else {return}
        // 4. All the plants must be connected horizontally or vertically.
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                guard self[p] != .empty else {continue}
                pos2node[p] = g.addNode(p.description)
            }
        }
        for (p, node) in pos2node {
            for os in ADifferentFarmerGame.offset {
                let p2 = p + os
                guard let node2 = pos2node[p2] else {continue}
                g.addEdge(node, neighbor: node2)
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
        if nodesExplored.count != pos2node.count { isSolved = false }
    }
}
